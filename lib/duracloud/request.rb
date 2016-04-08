require_relative "connection"
require_relative "response"
require_relative "request_options"

module Duracloud
  class Request
    attr_reader :client, :url, :http_method, :options

    def initialize(client, http_method, url, **options)
      @client      = client
      @http_method = http_method
      @url         = url
      @options = RequestOptions.new(**options)
    end

    def execute
      original_response = connection.send(http_method,
                                          url,
                                          body: options.payload,
                                          query: options.query,
                                          header: options.headers)
      response_class.new(original_response)
    end

    private

    def base_path
      '/'
    end

    def response_class
      Response
    end

    def connection
      @connection ||= Connection.new(client, base_path)
    end
  end
end
