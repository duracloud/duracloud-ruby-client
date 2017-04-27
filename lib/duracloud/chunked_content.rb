require 'nokogiri'

module Duracloud
  #
  # Duracluoud::ChunkedContent represents a content items that has been
  # split into multiple chunks (between 1-5Gb) due to the size of the
  # entire content stream.
  #
  class ChunkedContent < Content
    extend Forwardable

    MANIFEST_EXTENSION = ".dura-manifest"

    after_initialize :persisted!

    def self.find(**kwargs)
      new(**kwargs).tap do |content|
        content.manifest
        if content.md5 && ( content.md5 != content.manifest.md5 )
          raise MessageDigestError,
                "Expected MD5: {#{content.md5}}; DuraCloud MD5: {#{content.manifest.md5}}."
        end
      end
    end

    def manifest
      @manifest ||= ContentManifest.new(manifest_response.body)
    end

    def chunks
      Enumerator.new do |e|
        manifest.chunks.each do |c|
          e << Content.new(space_id: space_id,
                           content_id: c["chunkId"],
                           store_id: store_id,
                           md5: c.css("md5").text)
        end
      end
    end

    def download(&block)
      chunks.each { |chunk| chunk.download(&block) }
    end

    def properties
      @properties ||= properties_class.new(manifest_response.headers)
    end

    private

    def manifest_response
      @manifest_response ||= get_manifest_response
    end

    def get_manifest_response
      Client.get_content(*manifest_args, **query)
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
