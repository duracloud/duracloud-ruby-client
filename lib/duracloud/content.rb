require "uri"
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

    # Find content in DuraCloud.
    #
    # @param id [String] the content ID
    # @param space_id [String] the space ID.
    # @return [Duraclound::Content] the content
    # @raise [Duracloud::NotFoundError] the space or content ID does not exist.
    def self.find(id:, space_id:)
      new(id: id, space_id: space_id) do |content|
        content.load_properties
      end
    end

    # Store content in DuraCloud
    #
    # @param id [String] The content ID
    # @param space_id [String] The space ID.
    # @param body [String, #read] The content body
    # @return [Duracloud::Content] the content
    # @raise [Duracloud::NotFoundError] if the space ID does not exist
    # @raise [Duracloud::Error] if the body is empty.
    def self.create(id:, space_id:, body:)
      new(id: id, space_id: space_id) do |content|
        content.body = body
        yield content if block_given?
        content.save
      end
    end

    attr_reader :id, :space_id

    define_attribute_methods :content_type, :body, :md5

    # Initialize a new piece of content
    #
    # @param id [String] The content ID
    # @param space_id [String] The space ID
    #
    # @example
    #   new(id: mycontent.txt", space_id: "myspace")
    def initialize(id:, space_id:)
      @id = id.freeze
      @space_id = space_id.freeze
      @body = nil
      @content_type = nil
      @md5 = nil
      yield self if block_given?
    end

    def space
      Space.find(space_id)
    end

    def inspect
      "#<#{self.class} id=#{id.inspect}, space_id=#{space_id.inspect}>"
    end

    # @api private
    # @raise [Duracloud::NotFoundError] the content does not exist in DuraCloud.
    def load_body
      response = Client.get_content(url)
      @body = response.body # don't use setter
      persisted!
    end

    def load_properties
      super do |response|
        # don't mark content_type as changed
        @content_type = response.content_type
      end
    end

    def body=(str_or_io)
      val = read_string_or_io(str_or_io)
      raise ArgumentError, "Cannot set body to empty string." if val.empty?
      self.md5 = Digest::MD5.hexdigest(val)
      body_will_change! if md5_changed?
      @body = StringIO.new(val, "r")
    end

    def body
      load_body if persisted? && empty?
      @body
    end

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

    def md5
      @md5
    end

    private

    def md5=(val)
      md5_will_change! unless val == @md5
      @md5 = val
    end

    def set_properties
      headers = properties.to_h
      headers["Content-Type"] = content_type if content_type_changed?
      response = Client.set_content_properties(url, headers: headers)
      # response.body is a text message -- log?
    end

    def store
      headers = { "Content-MD5" => md5,
                  "Content-Type" => content_type || "application/octet-stream" }
      headers.merge!(properties)
      response = Client.store_content(url, body: body, headers: headers)
      # response.body is a text message -- log?
    end

    def url
      [space_id, id].join("/")
    end

    def properties_class
      ContentProperties
    end

    def get_properties_response
      Client.get_content_properties(url)
    end

    def do_delete
      Client.delete_content(url)
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

  end
end
