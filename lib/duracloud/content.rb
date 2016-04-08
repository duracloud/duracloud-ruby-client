require 'uri'
require 'forwardable'
require_relative 'content_properties'

module Duracloud
  #
  # A piece of content in DuraCloud
  #
  class Content
    extend Forwardable

    class << self
      def from_response(response)
        new(url: response.url) { |c| c.load_from_response(response) }
      end

      def find(**options)
        new(**options).get
      end

      def create(**options)
        new(**options).store
      end
    end

    attr_reader :url
    attr_accessor :md5, :content_type, :body

    delegate :empty? => :body

    alias_method :checksum, :md5

    def initialize(**options)
      url = if options[:url]
              options[:url]
            else
              unless options[:space_id] && options[:content_id]
                raise Error, "Content requires either :url OR both :space_id AND :content_id."
              end
              options.values_at(:space_id, :content_id).join('/')
            end
      @url = URI(url).path # might not be exactly what we want, but it works
      @body = options[:body] || options[:payload]
      @md5 = options[:md5]
      @content_type = options[:content_type]
      self.properties = options[:properties].to_h
      yield self if block_given?
    end

    def inspect
      "#<#{self.class} url=#{url.inspect}>"
    end

    def to_s
      body
    end

    def get
      response = client.get_content(url)
      load_from_response(response)
      self
    end
    alias_method :reload, :get

    def get_properties
      response = client.get_content_properties(url)
      load_properties_from_response(response)
      self
    end
    alias_method :reload_properties, :get_properties

    def set_properties
      self.content_type = "text/plain" unless content_type
      client.set_content_properties(url, properties: properties)
      self
    end

    def delete
      client.delete_content(url)
      reset
      freeze
      self
    end

    def store
      raise Error, "Refusing to store empty content file!" unless body
      self.md5 = Digest::MD5.hexdigest(body) unless md5
      unless content_type
        self.content_type = body ? "application/octet-stream" : "text/plain"
      end
      options = {
        payload: body, md5: md5, content_type: content_type, properties: properties
      }
      client.store_content(url, **options)
      reload_properties
      self
    end

    def load_from_response(response)
      self.body = response.body
      self.md5 = response.md5
      self.content_type = response.content_type
      load_properties_from_response(response)
    end

    def load_properties_from_response(response)
      self.properties = response.headers.select { |h, v| ContentProperties.property?(h) }
    end

    def properties
      @properties ||= ContentProperties.new
    end

    def properties=(props)
      properties.replace(props)
    end

    def client
      @client ||= Client.new
    end

    def reset
      properties.clear
      @body, @md5, @content_type = nil, nil, nil
    end
  end
end
