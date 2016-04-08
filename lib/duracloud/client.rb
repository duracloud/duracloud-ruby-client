require "forwardable"
require_relative "configuration"
require_relative "connection"
require_relative "content_request"

module Duracloud
  class Client
    extend Forwardable

    def self.configure
      yield Configuration
    end

    attr_reader :config

    delegate [:host, :port, :user, :password, :base_url] => :config

    def initialize(**options)
      @config = Configuration.new(**options)
    end

    def get_content(url, **options)
      execute ContentRequest, :get, url, **options
      #ContentRequest.get(self, url, **options)
    end

    def get_content_properties(url, **options)
      execute ContentRequest, :head, url, **options
    end

    def set_content_properties(url, **options)
      execute ContentRequest, :post, url, **options
    end

    def store_content(url, **options)
      execute ContentRequest, :put, url, **options
    end

    def delete_content(url, **options)
      execute ContentRequest, :delete, url, **options
    end

    def execute(request_class, http_method, url, **options)
      request_class.new(self, http_method, url, **options).execute
    end
  end
end
