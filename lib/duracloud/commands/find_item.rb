module Duracloud::Commands
  class FindItem < Command

    def call
      content = Duracloud::Content.find(space_id: space_id, store_id: store_id, content_id: content_id, md5: md5)
      props = content.properties.dup
      props.merge!("MD5" => content.md5,
                   "Size" => content.size,
                   "Chunked" => content.chunked?)
      props.each do |k, v|
        puts "#{k}: #{v}"
      end
    end

  end
end
