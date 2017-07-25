require "forwardable"
require "date"

module Duracloud
  class Response
    extend Forwardable

    attr_reader :original_response

    delegate [:header, :body, :code, :ok?, :redirect?, :status, :reason] => :original_response,
             :content_type => :header,
             :empty? => :body

    def_delegator :header, :request_uri, :url
    def_delegator :header, :request_method
    def_delegator :header, :request_query

    def initialize(original_response)
      @original_response = original_response
    end

    def error?
      !(ok? || redirect?)
    end

    def plain_text?
      content_type == "text/plain"
    end

    def has_body?
      !empty?
    end

    def headers
      header.all.each_with_object({}) do |(name, value), memo|
        memo[name] ||= []
        memo[name] << value
      end
    end

    def md5
      header["content-md5"].first
    end

    def size
      header["content-length"].first.to_i rescue nil
    end

    def modified
      DateTime.parse(header["last-modified"].first) rescue nil
    end
  end
end
