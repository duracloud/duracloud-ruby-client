require "forwardable"
require_relative "error_handler"

module Duracloud
  class Response
    extend Forwardable

    # class << self
    #   def error_handler
    #     @error_handler ||=
    #       begin
    #         class_name = self.name.split(/::/).last.sub(/Response\z/, "ErrorHandler")
    #         Duracloud.const_get(class_name)
    #       rescue NameError
    #         superclass.error_handler
    #       end
    #   end
    # end

    attr_reader :original_response

    delegate [:header, :body, :code, :ok?, :redirect?, :status, :reason] => :original_response,
             :content_type => :header,
             [:size, :empty?] => :body

    def_delegator :header, :request_uri, :url

    def initialize(original_response)
      @original_response = original_response
      #self.class.error_handler.call(self) if error?
      ErrorHandler.call(self) if error?
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
