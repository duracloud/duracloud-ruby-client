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

    delegate [:host, :port, :user, :password, :base_url, :logger] => :config

    def initialize(**options)
      @config = Configuration.new(**options)
    end

    def get_content(url, **options)
      execute ContentRequest, :get, url, **options
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

    private

    def execute(request_class, http_method, url, **options)
      request = request_class.new(self, http_method, url, **options)
      response = request.execute
      handle_response(response)
      response
    end

    def handle_response(response)
      logger.debug([self.class.to_s, response.request_method, response.url,
                    response.status, response.reason].join(' '))
      if response.error?
        ErrorHandler.call(response)
      elsif %w(POST PUT DELETE).include?(response.request_method) &&
            response.plain_text? &&
            response.has_body?
        logger.info(response.body)
      end
    end
  end
end
