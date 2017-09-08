require 'csv'

module Duracloud::Commands
  class FindItems < Command

    HEADERS = %i( content_id md5 size content_type modified )

    def call
      CSV.instance($stdout, headers: HEADERS, write_headers: true) do |csv|
        CSV.foreach(infile, headers: false) do |row|
          begin
            item = Duracloud::Content.find(space_id: space_id, store_id: store_id, content_id: row[0], md5: row[1])
            csv << HEADERS.map { |header| item.send(header) }
          rescue Duracloud::NotFoundError, Duracloud::MessageDigestError => e
            $stderr.puts "ERROR: Content ID #{row[0]} -- #{e.message}"
          end
        end
      end
    end

  end
end
