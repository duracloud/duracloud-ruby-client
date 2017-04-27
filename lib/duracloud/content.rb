module Duracloud
  #
  # A DuraCloud content item
  #
  class Content < AbstractEntity

    class CopyError < Error; end

    CHUNK_SIZE = 1024 * 16

    COPY_SOURCE_HEADER       = "x-dura-meta-copy-source"
    COPY_SOURCE_STORE_HEADER = "x-dura-meta-copy-source-store"

    attr_reader :space_id, :content_id, :store_id
    attr_accessor :body, :md5, :content_type
    alias_method :id, :content_id

    # Does the content exist in DuraCloud?
    # @return [Boolean] whether the content exists.
    # @raise [Duracloud::MessageDigestError] the provided digest in the :md5 keyword option,
    #   if given, does not match the stored value.
    def self.exist?(**kwargs)
      find(**kwargs) && true
    rescue NotFoundError
      false
    end

    # Find content in DuraCloud.
    # @return [Duraclound::Content] the content
    # @raise [Duracloud::NotFoundError] the space, content, or store (if given) does not exist.
    # @raise [Duracloud::MessageDigestError] the provided digest in the :md5 keyword option,
    #   if given, does not match the stored value.
    def self.find(**kwargs)
      new(**kwargs).tap do |content|
        content.persisted!
        content.properties
        if content.md5 && ( content.md5 != content.stored_md5 )
          raise MessageDigestError,
                "Expected MD5: {#{content.md5}}; DuraCloud MD5: {#{content.stored_md5}}."
        end
      end
    rescue NotFoundError
      ChunkedContent.find(**kwargs)
    end

    # Create new content in DuraCloud.
    # @return [Duraclound::Content] the content
    # @raise [Duracloud::NotFoundError] the space or store (if given) does not exist.
    # @raise [Duracloud::MessageDigestError] the provided digest in the :md5 keyword option,
    #   if given, does not match the stored value.
    def self.create(**kwargs)
      new(**kwargs).save
    end

    def initialize(space_id:, content_id:, store_id: nil, md5: nil)
      @space_id = space_id
      @content_id = content_id
      @store_id = store_id
      @md5 = md5
    end

    def stored_md5
      properties_response.md5
    end

    # Return the space associated with this content.
    # @return [Duracloud::Space] the space.
    # @raise [Duracloud::NotFoundError] the space or store does not exist.
    def space
      @space ||= Space.find(space_id, store_id)
    end

    def inspect
      "#<#{self.class} space_id=#{space_id.inspect}," \
      " content_id=#{content_id.inspect}," \
      " store_id=#{store_id || '(default)'}>"
    end

    def load_properties
      super do |response|
        if md5
          if md5 != response.md5
            raise MessageDigestError, "Expected MD5: {#{md5}}; DuraCloud MD5: {#{response.md5}}."
          end
        else
          self.md5 = response.md5
        end
        self.content_type = response.content_type
      end
    end

    # Is the content empty?
    # @return [Boolean] whether the content is empty (nil or empty string)
    def empty?
      body.nil? || ( body.respond_to?(:size) && body.size == 0 )
    end

    # Downloads the remote content
    # @yield [String] chunk of the remote content, if block given.
    # @return [Duracloud::Response] the response to the content request.
    # @raise [Duracloud::NotFoundError]
    def download(&block)
      Client.get_content(*args, **query, &block)
    end

    # @return [Duracloud::Content] the copied content
    #   The current instance still represents the original content.
    def copy(**args)
      dest = args.except(:force)
      dest[:space_id]   ||= space_id
      dest[:content_id] ||= content_id
      raise CopyError, "Destination is the same as the source." if dest == copy_source
      if !args[:force] && Content.exist?(**dest)
        raise CopyError, "Destination exists and :force option is false."
      end
      options = { storeID: dest[:store_id], headers: copy_headers }
      Client.copy_content(dest[:space_id], dest[:content_id], **options)
      Content.new(dest.merge(md5: md5))
    end

    # @return [Duracloud::Content] the moved content
    #   The current instance still represents the deleted content.
    def move(**args)
      copied = copy(**args)
      delete
      copied
    end

    private

    def store
      headers = {
        "Content-MD5"  => md5 || calculate_md5,
        "Content-Type" => content_type || "application/octet-stream"
      }
      headers.merge!(properties)
      options = { body: body, headers: headers, query: query }
      Client.store_content(*args, **options)
    end

    def copy_headers
      ch = { COPY_SOURCE_HEADER=>"#{space_id}/#{content_id}" }
      ch[COPY_SOURCE_STORE_HEADER] = store_id if store_id
      ch
    end

    def copy_source
      { space_id: space_id, content_id: content_id, store_id: store_id }
    end

    def io_like?
      body.respond_to?(:read) && body.respond_to?(:rewind)
    end

    def set_properties
      headers = properties.to_h
      options = { headers: headers, query: query }
      Client.set_content_properties(*args, **options)
    end

    def calculate_md5
      digest = Digest::MD5.new
      if io_like?
        body.rewind
        while chunk = body.read(CHUNK_SIZE) do
          digest << chunk
        end
        body.rewind
      else
        digest << body
      end
      digest.hexdigest
    end

    def properties_class
      ContentProperties
    end

    def get_properties_response
      Client.get_content_properties(*args, **query)
    end

    def do_delete
      Client.delete_content(*args, **query)
    end

    def do_save
      if !empty?
        store
      elsif persisted?
        set_properties
      else
        raise Error, "Cannot store empty content."
      end
    end

    def args
      [ space_id, content_id ]
    end

    def query
      { storeID: store_id }
    end

  end
end
