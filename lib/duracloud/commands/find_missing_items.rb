module Duracloud::Commands
  class FindMissingItems < Command

    def call
      CSV.instance($stdout, headers: false) do |csv|
        CSV.foreach(infile, headers: false) do |row|
          unless Duracloud::Content.exist?(space_id: space_id, store_id: store_id, content_id: row[0], md5: row[1])
            csv << row
          end
        end
      end
    end

  end
end
