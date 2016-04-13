require 'uri'
require 'active_model'
require 'active_support/core_ext/object/blank'
require_relative 'content_properties'

module Duracloud
  #
  # A piece of content in DuraCloud
  #
  class Content
    include ActiveModel::Dirty

    # Find content in DuraCloud.
    #
    # Requires:
    #
    #   :url - Relative or absolute URL to content.
    #
    #   OR
    #
    #   :space_id - ID of DuraCloud space
    #   :content_id - ID of DuraClound content
    #
    # @return [Duraclound::Content] the content
    # @raise [Duracloud::NotFoundError]
    def self.find(**options)
      content = allocate
      content.set_url(**options)
      content.load_properties
      content
    end

    # Store content in DuraCloud
    #
    # Requires:
    #
    #   :body - the content payload (string)
    #
    #   AND EITHER
    #
    #   :url - Relative or absolute URL to content.
    #
    #   OR
    #
    #   :space_id - ID of DuraCloud space
    #   :content_id - ID of DuraClound content
    #
    # @return [Duraclound::Content] the content
    # @raise [Duracloud::NotFoundError] if the DuraCloud space does not exist
    # @raise [Duracloud::Error] if the body is empty.
    def self.create(**options)
      content = new(**options)
      content.save
      content
    end

    attr_reader :url

    define_attribute_methods :content_type, :body, :md5

    # Initialize a new piece of content
    #
    # :body [String] the content payload (optional)
    # :md5 [String] the MD5 checksum of the payload (optional)
    # :url [String] the relative or absolute URL of the content in DuraCloud
    #   (current or to be stored; required unless :space_id and :content_id given)
    # :space_id [String] the ID of the DuraCloud space (for new content;
    #    required unless :url given)
    # :content_id [String] the ID of the DuraCloud content (for new content,
    #   required unless :url given)
    # :content_type [String] the media type of the content (optional)
    # :properties [Hash custom properties to set on the content (optional)
    #
    # @example
    #   new(url: "myspace/mycontent.txt", body: "Store me!", content_type: "text/plain")
    # @example
    #   new(space_id: "myspace", content_id: "mycontent.txt", body: "Store me!",
    #       content_type: "text/plain")
    #
    # @raise [Duracloud::Error] invalid or missing URL options
    def initialize(**options)
      set_url(**options)
      self.body = options[:body]
      self.md5  = options[:md5]
      self.content_type = options[:content_type]
      self.properties = options[:properties]
    end

    def inspect
      "#<#{self.class} url=#{url.inspect}, content_type=#{content_type.inspect}>"
    end

    # @api private
    # @raise [Duracloud::NotFoundError] the content does not exist in DuraCloud.
    def load_body
      response = client.get_content(url)
      @body = response.body # don't use setter
      persisted!
    end

    # @api private
    # @raise [Duracloud::NotFoundError] the content does not exist in Duracloud.
    def load_properties
      response = client.get_content_properties(url)
      @content_type = response.content_type # don't mark content_type as changed
      self.properties = response.headers
      persisted!
    end

    # The custom properties of the content
    # @return [Duracloud::ContentProperties]
    def properties
      load_properties if persisted? && @properties.blank?
      @properties
    end

    def body=(val)
      if persisted? && val.blank?
        raise Error, "Cannot set persisted content to empty string or nil."
      end
      body_will_change! unless val == @body
      @body = val
    end

    def body
      load_body if persisted? && empty?
      @body
    end

    def empty?
      @body.blank?
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

    # Persist the content body (if present and changed) and/or properties.
    # @raise [Duracloud::NotFoundError] the Duracloud space or content ID does not exist.
    # @raise [Duracloud::Error] attempted to store empty content.
    # @return [Duracloud::Content] self
    def save
      raise Error, "Cannot save deleted content." if deleted?
      if !empty? && body_changed?
        store
      elsif persisted?
        set_properties
      else
        raise Error, "Cannot store empty content."
      end
      persisted!
      changes_applied
      reset_properties
      self
    end

    # Delete the content from DuraCloud
    # @raise [Duracloud::NotFoundError] the content does not exist in DuraCloud.
    # @return [Duracloud::Content] self
    def delete
      client.delete_content(url)
      reset_properties
      freeze
      deleted!
      self
    end

    def persisted?
      !!@persisted
    end

    def deleted?
      !!@deleted
    end

    # @api private
    def set_url(**options)
      u = if options[:url].present?
            options[:url]
          else
            unless options[:space_id].present? && options[:content_id].present?
              raise ArgumentError,
                    "Requires either :url option OR both :space_id AND :content_id options."
            end
            options.values_at(:space_id, :content_id).join('/')
          end
      @url = URI(u).path # XXX might not be exactly what we want, but it works
      @url.freeze
    end

    protected

    def method_missing(name, *args, &block)
      properties.send(name, *args, &block)
    rescue Error, ::NoMethodError
      super
    end

    private

    def properties=(props)
      filtered = props ? ContentProperties.filter(props) : props
      @properties = ContentProperties.new(filtered)
    end

    def reset_properties
      self.properties = nil
    end

    # @raise [Duracloud::NotFoundError]
    # @return [Duracloud::Content] self
    def set_properties
      options = { properties: properties }
      options[:content_type] = content_type if content_type_changed?
      response = client.set_content_properties(url, **options)
      # response.body is a text message -- log?
    end

    # @raise [Duracloud::Error] if body is empty
    # @raise [Duracloud::NotFoundError] if the space does not exist
    def store
      options = {
        body:         body,
        md5:          md5 || Digest::MD5.hexdigest(body),
        content_type: content_type || "application/octet-stream",
        properties:   properties
      }
      response = client.store_content(url, **options)
      # response.body is a text message -- log?
    end

    def persisted!
      @persisted = true
    end

    def deleted!
      @deleted = true
    end

    def client
      @client ||= Client.new
    end
  end
end
