module Duracloud
  class Request
    attr_reader :client, :url, :http_method, :body, :headers, :query

    # @param client [Duracloud::Client] the client
    # @param http_method [Symbol] the lower-case symbol corresponding to HTTP method
    # @param url [String] relative or absolute URL
    # @param options [Hash] options
    # @option options [String] :body the body of the request
    # @option options [Hash] :headers HTTP headers
    # @option options [Hash] :query query string parameters
    def initialize(client, http_method, url, **options)
      @client      = client
      @http_method = http_method
      @url         = url
      set_options(options.dup)
    end

    def execute
      response_class.new(original_response)
    end

    private

    def original_response
      connection.send(http_method,
                      url,
                      body: body,
                      query: query,
                      header: headers)
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
