module Duracloud::Commands
  class StoreContent < Command

    def call
      File.open(infile, "rb") do |body|
        Duracloud::Content.create(space_id: space_id, store_id: store_id,
                                  content_id: content_id, body: body,
                                  md5: md5, content_type: content_type)
      end
    end

  end
end
