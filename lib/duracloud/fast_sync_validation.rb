module Duracloud
  class FastSyncValidation < SyncValidation

    def download_manifest
      if prefix
        File.open(manifest_filename, "w") do |manifest|
          Space.content_ids(space_id, store_id: store_id, prefix: prefix).each do |content_id|
            manifest.puts content_id
          end
        end
      else
        super
      end
    end

    def convert_manifest
      cut_opts = prefix ? "-c #{prefix.length}-" : "-f 2" # content-id is 2nd field of DuraCloud manifest
      system("cut #{cut_opts} #{manifest_filename} | sort", out: converted_manifest_filename)
    end

    def audit
      find_files
      if system("comm", "-23", find_filename, converted_manifest_filename, out: audit_filename)
        File.zero?(audit_filename) || recheck
      else
        raise Error, "Error comparing #{find_filename} with #{converted_manifest_filename}."
      end
    end

    def find_files
      # TODO handle exclude file?
      outfile = File.join(FileUtils.pwd, find_filename)
      # Using a separate command for sort so we get find results incrementally
      system("find -L . -type f | sed -e 's|^\./|#{prefix}|'", chdir: content_dir, out: outfile) &&
        system("sort", "-o", find_filename, find_filename)
    end

    private

    def do_recheck
      Enumerator.new do |e|
        File.foreach(audit_filename) do |line|
          content_id = line.chomp
          e << check(content_id)
        end
      end
    end

    def find_filename
      filename("find.txt")
    end

  end
end
