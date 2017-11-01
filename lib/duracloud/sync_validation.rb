require 'tempfile'
require 'csv'
require 'fileutils'
require 'hashie'

module Duracloud
  class SyncValidation < Hashie::Dash

    TWO_SPACES = '  '
    MD5_CSV_OPTS = { col_sep: TWO_SPACES }.freeze
    MANIFEST_CSV_OPTS = { col_sep: "\t", headers: true, return_headers: false }.freeze

    MISSING = "MISSING"
    CHANGED = "CHANGED"
    FOUND   = "FOUND"

    property :space_id, required: true
    property :content_dir, required: true
    property :store_id
    property :work_dir

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
      File.open(converted_manifest_filename, "w") do |f|
        CSV.foreach(manifest_filename, MANIFEST_CSV_OPTS) do |row|
          f.puts [ row[2], row[1] ].join(TWO_SPACES)
        end
      end
    end

    def audit
      outfile = File.join(FileUtils.pwd, audit_filename)
      infile = File.join(FileUtils.pwd, converted_manifest_filename)
      pid = spawn("md5deep", "-X", infile, "-l", "-r", ".", chdir: content_dir, out: outfile)
      Process.wait(pid)
      case $?.exitstatus
      when 0
        true
      when 1, 2
        recheck
      when 64, 128
        raise Error, "md5deep error."
      else
        raise Error, "Unknown error."
      end
    end

    def recheck
      success = true
      recheck_file do |csv|
        do_recheck.each do |result|
          csv << result.to_a
          success &&= result.found?
        end
      end
      success
    end

    private

    CheckResult = Struct.new(:status, :md5, :content_id) do
      def found?
        status == FOUND
      end
    end

    def recheck_file
      if work_dir
        CSV.open(recheck_filename, "w", col_sep: "\t") { |csv| yield(csv) }
      else
        CSV($stdout, col_sep: "\t") { |csv| yield(csv) }
      end
    end

    def check(content_id, md5 = nil)
      status = begin
                 exist?(content_id, md5) ? FOUND : MISSING
               rescue MessageDigestError => e
                 CHANGED
               end
      CheckResult.new(status, md5 || "-", content_id)
    end

    def exist?(content_id, md5 = nil)
      Duracloud::Content.exist?(space_id: space_id, store_id: store_id, content_id: content_id, md5: md5)
    end

    def do_recheck
      Enumerator.new do |e|
        CSV.foreach(audit_filename, MD5_CSV_OPTS) do |md5, path|
          content_id = path.sub(/^\.\//, "")
          e << check(content_id, md5)
        end
      end
    end

    def prefix
      space_id
    end

    def filename(suffix)
      [ prefix, suffix ].join("-")
    end

    def manifest_filename
      filename("manifest.tsv")
    end

    def converted_manifest_filename
      filename("converted-manifest.txt")
    end

    def audit_filename
      filename("audit.txt")
    end

    def recheck_filename
      filename("recheck.txt")
    end

  end
end
