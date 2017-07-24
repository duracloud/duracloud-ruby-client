require 'active_model'
require 'tempfile'
require 'csv'

module Duracloud
  class SyncValidation
    include ActiveModel::Model

    TWO_SPACES = '  '

    MD5_CSV_OPTS = { col_sep: TWO_SPACES }.freeze
    MANIFEST_CSV_OPTS = { col_sep: "\t", headers: true, return_headers: false }.freeze
    CHECK_CSV_OPTS = { col_sep: "\t" }

    MISSING = "MISSING"
    CHANGED = "CHANGED"
    FOUND   = "FOUND"

    attr_accessor :space_id, :content_dir, :store_id

    def self.call(**kwargs)
      new(**kwargs).call
    end

    def self.check_missing(**kwargs)
      infile = kwargs.delete(:infile)
      new(**kwargs).check_missing(infile)
    end

    def check(content_id:, md5: nil)
      Duracloud::Content.exist?(
        space_id: space_id,
        store_id: store_id,
        content_id: content_id,
        md5: md5
      ) ? FOUND : MISSING
    rescue MessageDigestError => e
      CHANGED
    end

    def check_missing(infile)
      CSV($stdout, CHECK_CSV_OPTS) do |output|
        CSV.foreach(infile, col_sep: "\t") do |old_status, md5, content_id|
          next unless old_status == MISSING
          status = check(content_id: content_id, md5: md5)
          output << [ status, md5, content_id ]
        end
      end
    end

    def call
      Tempfile.open("#{space_id}-manifest") do |manifest|
        Manifest.download(space_id, store_id) do |chunk|
          manifest.write(chunk)
        end
        manifest.close

        # convert manifest into md5deep format
        Tempfile.open("#{space_id}-md5") do |md5_list|
          CSV.foreach(manifest.path, MANIFEST_CSV_OPTS) do |row|
            md5_list.puts [ row[2], row[1] ].join(TWO_SPACES)
          end
          md5_list.close

          # run md5deep to find files not listed in the manifest
          Tempfile.open("#{space_id}-audit") do |audit|
            audit.close
            pid = spawn("md5deep", "-X", md5_list.path, "-l", "-r", ".", chdir: content_dir, out: audit.path)
            Process.wait(pid)
            case $?.exitstatus
            when 0
              true
            when 1, 2
              passed = true
              CSV($stdout, CHECK_CSV_OPTS) do |output|
                CSV.foreach(audit.path, MD5_CSV_OPTS) do |md5, path|
                  content_id = path.sub(/^\.\//, "")
                  status = check(content_id: content_id, md5: md5)
                  passed &&= ( status == FOUND )
                  output << [ status, md5, content_id ]
                end
              end
              passed
            when 64
              raise Error, "md5deep user error."
            when 128
              raise Error, "md5deep internal error."
            end
          end
        end
      end
    end

  end
end
