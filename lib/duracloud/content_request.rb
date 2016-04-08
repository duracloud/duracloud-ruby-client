require "digest"
require_relative "request"
require_relative "content_response"
require_relative "connection"

module Duracloud
  class ContentRequest < Request
    def base_path
      '/durastore/'
    end

    def response_class
      ContentResponse
    end
  end
end
