require "forwardable"

module Duracloud
  class Client
    extend Forwardable
    extend RestMethods
    include RestMethods

    def self.execute(request_class, http_method, url, **options, &block)
      new.execute(request_class, http_method, url, **options, &block)
    end

    def self.configure
      yield Configuration
    end

    attr_reader :config

    delegate [:host, :port, :user, :password, :base_url, :logger] => :config

    def initialize(**options)
      @config = Configuration.new(**options)
    end

    def execute(request_class, http_method, url, **options, &block)
      request = request_class.new(self, http_method, url, **options)
      response = request.execute(&block)
      handle_response(response)
      response
    end

    private

    def handle_response(response)
      logger.debug([self.class.to_s, response.request_method, response.url, response.request_query,
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
