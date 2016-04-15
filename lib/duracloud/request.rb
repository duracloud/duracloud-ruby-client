require "duracloud/connection"
require "duracloud/response"

module Duracloud
  class Request
    attr_reader :client, :url, :http_method, :body, :headers, :query

    # @param client [Duracloud::Client] the client
    # @param http_method [Symbol] the lower-case symbol corresponding to HTTP method
    # @param url [String] relative or absolute URL
    # @param body [String] the body of the request
    # @param headers [Hash] HTTP headers
    # @param query [Hash] Query string parameters
    def initialize(client, http_method, url, body: nil, headers: nil, query: nil)
      @client      = client
      @http_method = http_method
      @url         = url
      @body        = body
      @headers     = headers
      @query       = query
    end

    def execute
      begin
        original_response = connection.send(http_method,
                                            url,
                                            body: body,
                                            query: query,
                                            header: headers)
        Response.new(original_response)
      end
    end

    private

    def base_path
      '/'
    end

    def connection
      @connection ||= Connection.new(client, base_path)
    end
  end
end
