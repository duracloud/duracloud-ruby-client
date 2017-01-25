require "active_model"

module Duracloud
  #
  # A piece of content in DuraCloud
  #
  class Content
    include ActiveModel::Model
    include ActiveModel::Dirty
    include Persistence
    include HasProperties

    CHUNK_SIZE = 1024 * 16

    after_save :changes_applied

    # Does the content exist in DuraCloud?
    # @see .new for arguments
    # @return [Boolean] whether the content exists
    def self.exist?(*args)
      find(*args) && true
    rescue NotFoundError
      false
    end

    # Find content in DuraCloud.
    # @return [Duraclound::Content] the content
    # @raise [Duracloud::NotFoundError] the space, content, or store does not exist.
    def self.find(*args)
      new(*args) { |content| content.load_properties }
    end

    attr_accessor :space_id, :content_id, :store_id
    alias_method :id, :content_id
    validates_presence_of :space_id, :content_id

    define_attribute_methods :content_type, :body, :md5

    def initialize(params={})
      super
      yield self if block_given?
    end

    # Return the space associated with this content.
    # @return [Duracloud::Space] the space.
    # @raise [Duracloud::NotFoundError] the space or store does not exist.
    def space
      Space.find(space_id, store_id)
    end

    def inspect
      "#<#{self.class} space_id=#{space_id.inspect}," \
      " content_id=#{content_id.inspect}," \
      " store_id=#{store_id || '(default)'}>"
    end

    # @api private
    # @raise [Duracloud::NotFoundError] the content does not exist in DuraCloud.
    def load_body
      response = Client.get_content(*args, **query)
      set_md5!(response)
      @body = response.body # don't use setter b/c marks as dirty
      persisted!
    end

    def load_properties
      super do |response|
        # don't mark content_type or md5 as changed
        set_md5!(response)
        @content_type = response.content_type
      end
    end

    def body=(str_or_io)
      @body = str_or_io
      body_will_change!
    end

    # Return the content body, loading from DuraCloud if necessary.
    # @return [String, StringIO] the content body
    def body
      load_body if persisted? && empty?
      @body
    end

    # Is the content empty?
    # @return [Boolean] whether the content is empty (nil or empty string)
    def empty?
      @body.nil? || @body.size == 0
    end

    def content_type=(val)
      content_type_will_change! unless val == @content_type
      @content_type = val
    end

    def content_type
      @content_type
    end

    def md5=(val)
      md5_will_change! unless val == @md5
      @md5 = val
    end

    def md5
      @md5
    end

    private

    def set_md5!(response)
      if md5
        if md5 != response.md5
          raise MessageDigestError,
                "Expected MD5 digest (#{md5}) does not match response header: #{response.md5}"
        end
      else
        @md5 = response.md5
      end
    end

    def io_like?
      body.respond_to?(:read) && body.respond_to?(:rewind)
    end

    def set_properties
      headers = properties.to_h
      headers["Content-Type"] = content_type if content_type_changed?
      options = { headers: headers, query: query }
      Client.set_content_properties(*args, **options)
    end

    def store
      headers = {
        "Content-MD5"  => md5 || calculate_md5,
        "Content-Type" => content_type || "application/octet-stream"
      }
      headers.merge!(properties)
      options = { body: body, headers: headers, query: query }
      Client.store_content(*args, **options)
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
      if !empty? && body_changed?
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
