module Duracloud
  class Request
    attr_reader :client, :url, :http_method, :body, :headers, :query

    # @param client [Duracloud::Client] the client
    # @param http_method [Symbol] the lower-case symbol corresponding to HTTP method
    # @param url [String] relative or absolute URL
    # @param body [String] the body of the request
    # @param headers [Hash] HTTP headers
    # @param query [Hash] Query string parameters
    # def initialize(client, http_method, url, body: nil, headers: nil, query: nil)
    def initialize(client, http_method, url, **options)
      @client      = client
      @http_method = http_method
      @url         = url
      set_options(options.dup)
    end

    def execute(&block)
      response_class.new original_response(&block)
    end

    private

    def original_response(&block)
      connection.send(http_method,
                      url,
                      body: body,
                      query: query,
                      header: headers,
                      &block)
    end

    def set_options(options)
      @body    = options.delete(:body)
      @headers = options.delete(:headers)
      query    = options.delete(:query) || {}
      # Treat other keywords args as query params and ignore empty params
      @query = query.merge(options).reject { |k, v| v.to_s.empty? }
    end

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
