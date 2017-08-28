require_relative "command"
require "csv"

module Duracloud::Commands
  class ListItems < Command

    HEADERS = %i( content_id md5 size content_type modified )

    def call
      ::CSV.instance($stdout, headers: HEADERS, write_headers: true) do |csv|
        Duracloud::Space.items(space_id, store_id: store_id, prefix: prefix).each do |item|
          csv << HEADERS.map { |header| item.send(header) }
        end
      end
    end

  end
end
