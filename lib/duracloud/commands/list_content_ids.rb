require_relative "command"

module Duracloud::Commands
  class ListContentIds < Command

    def call
      Duracloud::Space.content_ids(space_id, store_id: store_id, prefix: prefix).each do |id|
        puts id
      end
    end

  end
end
