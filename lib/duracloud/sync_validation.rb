require 'active_model'
require 'tempfile'
require 'csv'
require 'fileutils'

module Duracloud
  class SyncValidation
    include ActiveModel::Model

    TWO_SPACES = '  '
    MD5_CSV_OPTS = { col_sep: TWO_SPACES }.freeze
    MANIFEST_CSV_OPTS = { col_sep: "\t", headers: true, return_headers: false }.freeze

    MISSING = "MISSING"
    CHANGED = "CHANGED"
    FOUND   = "FOUND"

    attr_accessor :space_id, :content_dir, :store_id, :work_dir

    def self.call(*args)
      new(*args).call
    end

    def in_work_dir
      if work_dir
        FileUtils.cd(work_dir) { yield }
      else
        Dir.mktmpdir("#{space_id}-validation-") do |tmpdir|
          FileUtils.cd(tmpdir) { yield }
        end
      end
    end

    def call
      in_work_dir do
        download_manifest
        convert_manifest
        audit
      end
    end

    def download_manifest
      File.open(manifest_filename, "w") do |manifest|
        Manifest.download(space_id, store_id) do |chunk|
          manifest.write(chunk)
        end
      end
    end

    def convert_manifest
      File.open(md5_filename, "w") do |f|
        CSV.foreach(manifest_filename, MANIFEST_CSV_OPTS) do |row|
          f.puts [ row[2], row[1] ].join(TWO_SPACES)
        end
      end
    end

    def audit
      outfile = File.join(FileUtils.pwd, audit_filename)
      infile = File.join(FileUtils.pwd, md5_filename)
      pid = spawn("md5deep", "-X", infile, "-l", "-r", ".", chdir: content_dir, out: outfile)
      Process.wait(pid)
      case $?.exitstatus
      when 0
        true
      when 1, 2
        recheck_failures
      when 64, 128
        raise Error, "md5deep error."
      else
        raise Error, "Unknown error."
      end
    end

    def recheck_failures
      success = true
      CSV($stdout, col_sep: "\t") do |output|
        CSV.foreach(audit_filename, MD5_CSV_OPTS) do |md5, path|
          content_id = path.sub(/^\.\//, "")
          status = begin
                     if Duracloud::Content.exist?(space_id: space_id, store_id: store_id, content_id: content_id, md5: md5)
                       FOUND
                     else
                       MISSING
                     end
                   rescue MessageDigestError => e
                     CHANGED
                   end
          output << [ status, md5, content_id ]
          success &&= ( status == FOUND )
        end
      end
      success
    end

    def manifest_filename
      "#{space_id}-manifest.tsv"
    end

    def md5_filename
      "#{space_id}-md5.txt"
    end

    def audit_filename
      "#{space_id}-audit.txt"
    end

  end
end
