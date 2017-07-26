require_relative "command"

module Duracloud::Commands
  class GetProperties < Command

    def call
      proplist = content_id ? content_properties : space_properties
      puts proplist
    end

    private

    def content_properties
      content = Duracloud::Content.find(space_id: space_id, store_id: store_id, content_id: content_id, md5: md5)
      proplist = content.properties.map { |k, v| "#{k}: #{v}" }
      proplist << "MD5: #{content.md5}"
      proplist << "Size: #{content.size} (#{content.human_size})"
      proplist << "Chunked?: #{content.chunked?}"
    end

    def space_properties
      space = Duracloud::Space.find(space_id, store_id)
      space.properties.map { |k, v| "#{k}: #{v}" }
    end

  end
end
