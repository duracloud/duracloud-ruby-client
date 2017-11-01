require 'addressable/uri'
require 'httpclient'

module Duracloud
  class Request

    attr_reader :url, :http_method, :body, :headers, :query

    def self.execute(http_method, url, **options, &block)
      request = new(http_method, url, **options)
      request.execute(&block)
    end

    # @param http_method [Symbol] the lower-case symbol corresponding to HTTP method
    # @param url [String] relative or absolute URL
    # @param body [String] the body of the request
    # @param headers [Hash] HTTP headers
    # @param query [Hash] Query string parameters
    # def initialize(client, http_method, url, body: nil, headers: nil, query: nil)
    def initialize(http_method, url, **options)
      @http_method = http_method
      @url         = Addressable::URI.parse(url).normalize.to_s
      set_options(options.dup)
    end

    def execute(&block)
      Response.new(original_response(&block)).tap do |response|
        log_request(response)
      end
    end

    private

    def log_request(response)
      message = [ self.class.to_s,
                  response.request_method,
                  response.request_uri,
                  response.request_query,
                  response.status,
                  response.reason
                ].join(' ')
      Duracloud.logger.debug(message)
    end

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

    # @return [HTTPClient] An HTTP connection to DuraCloud.
    # @note We are using HTTPClient because Net::HTTP capitalizes
    # request header names which is incompatible with DuraCloud's
    # custom case-sensitive content property headers (x-dura-meta-*).
    def connection
      HTTPClient.new(base_url: Duracloud.base_url, force_basic_auth: Duracloud.auth?).tap do |conn|
        conn.set_auth(Duracloud.base_url, Duracloud.user, Duracloud.password) if Duracloud.auth?
      end
    end
  end
end
