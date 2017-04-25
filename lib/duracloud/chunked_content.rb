require 'nokogiri'

module Duracloud
  class ChunkedContent < Content

    MANIFEST_EXTENSION = ".dura-manifest"

    def manifest
      @manifest ||= Nokogiri::XML(get_manifest)
    end

    def md5
      manifest.css("sourceContent md5").text
    end

    def size
      manifest.css("sourceContent byteSize").text.to_i
    end

    def content_type
      manifest.css("sourceContent mimetype").text
    end

    def chunks
      Enumerator.new do |e|
        manifest.css("chunk").each do |c|
          e << Content.find(space_id: space_id,
                            content_id: c["chunkId"],
                            store_id: store_id,
                            md5: c.css("md5").text)
        end
      end
    end

    def body
      Enumerator.new do |e|
        chunks.each do |chunk|
          e << chunk.body
        end
      end
    end

    private

    def set_md5!(response)
    end

    def get_manifest
      Client.get_content(*manifest_args, **query).body
    end

    def get_properties_response
      Client.get_content_properties(*manifest_args, **query)
    end

    def manifest_args
      [ space_id, manifest_content_id ]
    end

    def manifest_content_id
      content_id + MANIFEST_EXTENSION
    end

  end
end
