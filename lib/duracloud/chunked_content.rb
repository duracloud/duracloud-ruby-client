module Duracloud
  class ChunkedContent < Content

    def self.find(**kwargs)
      new(**kwargs).tap do |content|
        content.manifest
      end
    end

    def manifest
      if @manifest.nil?
        @manifest = ContentManifest.find(space_id: space_id,
                                         manifest_id: content_id + MANIFEST_EXT,
                                         store_id: store_id)
        load_properties
      end
      @manifest
    end

    def chunked?
      true
    end

    private

    def do_load_properties
      if md5
        if md5 != manifest.source.md5
          raise MessageDigestError, "Expected MD5: {#{md5}}; DuraCloud MD5: {#{manifest.source.md5}}."
        end
      else
        self.md5 = manifest.source.md5
      end
      self.properties = manifest.properties.dup
      self.content_type = manifest.source.content_type
      self.size = manifest.source.size
      self.modified = manifest.content.modified
    end

  end
end
