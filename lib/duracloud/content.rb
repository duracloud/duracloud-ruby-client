require "stringio"
require "active_model"

module Duracloud
  #
  # A piece of content in DuraCloud
  #
  class Content
    include ActiveModel::Dirty
    include Persistence
    include HasProperties

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
    # @see .new for arguments
    # @return [Duraclound::Content] the content
    # @raise [Duracloud::NotFoundError] the space, content, or store does not exist.
    def self.find(*args)
      new(*args) { |content| content.load_properties }
    end

    attr_reader :space_id, :content_id, :store_id
    alias_method :id, :content_id

    define_attribute_methods :content_type, :body

    # @param space_id [String] The space ID (required)
    # @param content_id [String] The content ID (required)
    # @param store_id [String] the store ID (optional)
    # @example
    #   new("myspace", "mycontent.txt")
    def initialize(space_id, content_id, store_id = nil)
      @content_id = content_id
      @space_id = space_id
      @store_id = store_id
      @body, @content_type = nil, nil
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
      set_body(response) # don't use setter b/c marks as dirty
      persisted!
    end

    def load_properties
      super do |response|
        # don't mark content_type as changed
        @content_type = response.content_type
      end
    end

    def body=(str_or_io)
      set_body(str_or_io)
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

    private

    def set_body(str_or_io)
      @body = StringIO.new(read_string_or_io(str_or_io), "r")
    end

    def set_properties
      headers = properties.to_h
      headers["Content-Type"] = content_type if content_type_changed?
      options = { headers: headers, query: query }
      Client.set_content_properties(*args, **options)
    end

    def store
      headers = {
        "Content-MD5"  => md5,
        "Content-Type" => content_type || "application/octet-stream"
      }
      headers.merge!(properties)
      options = { body: body, headers: headers, query: query }
      Client.store_content(*args, **options)
    end

    def md5
      body.rewind
      Digest::MD5.hexdigest(body.read)
    ensure
      body.rewind
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

    def read_string_or_io(str_or_io)
      if str_or_io.respond_to?(:read)
        read_io_like(str_or_io)
      elsif str_or_io.respond_to?(:to_str)
        str_or_io.to_str
      else
        raise ArgumentError, "IO-like or String-like argument required."
      end
    end

    def read_io_like(io_like)
      begin
        io_like.rewind if io_like.respond_to?(:rewind)
        io_like.read
      ensure
        io_like.rewind if io_like.respond_to?(:rewind)
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
