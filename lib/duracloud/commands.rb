module Duracloud
  module Commands

    def validate
      SyncValidation.call(space_id: space_id, store_id: store_id, content_dir: content_dir)
    end

    def manifest
      Manifest.download(space_id, store_id, format: format) do |chunk|
        print chunk
      end
    end

    def properties
      proplist = content_id ? content_properties : space_properties
      STDOUT.puts proplist
    end

    private

    def content_properties
      content = Content.find(space_id: space_id, store_id: store_id, content_id: content_id, md5: md5)
      proplist = content.properties.map { |k, v| "#{k}: #{v}" }
      proplist << "MD5: #{content.md5}"
      proplist << "Size: #{content.size} (#{content.human_size})"
      proplist << "Chunked?: #{content.chunked?}"
    end

    def space_properties
      space = Space.find(space_id, store_id)
      space.properties.map { |k, v| "#{k}: #{v}" }
    end

  end
end
