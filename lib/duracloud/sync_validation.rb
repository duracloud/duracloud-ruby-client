require 'active_model'
require 'tempfile'
require 'csv'

module Duracloud
  class SyncValidation
    include ActiveModel::Model

    TWO_SPACES = '  '
    MD5_CSV_OPTS = { col_sep: TWO_SPACES }.freeze
    MANIFEST_CSV_OPTS = { col_sep: "\t", headers: true, return_headers: false }.freeze

    attr_accessor :space_id, :content_dir, :store_id

    def self.call(*args)
      new(*args).call
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
              failures = []
              CSV.foreach(audit.path, MD5_CSV_OPTS) do |md5, path|
                content_id = path.sub(/^\.\//, "")
                begin
                  if !Duracloud::Content.exist?(space_id: space_id, store_id: store_id, content_id: content_id, md5: md5)
                    failures << [ "MISSING", md5, content_id ].join("\t")
                  end
                rescue MessageDigestError => e
                  failures << [ "CHANGED", md5, content_id ].join("\t")
                end
              end
              STDOUT.puts failures
              failures.empty?
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
