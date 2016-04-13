require "forwardable"
require_relative "error_handler"

module Duracloud
  class Response
    extend Forwardable

    attr_reader :original_response

    delegate [:header, :body, :code, :ok?, :redirect?, :status, :reason] => :original_response,
             :content_type => :header,
             [:size, :empty?] => :body

    def_delegator :header, :request_uri, :url
    def_delegator :header, :request_method

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
  end
end
