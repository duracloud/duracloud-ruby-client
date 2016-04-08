module Duracloud
  class ErrorHandler
    def self.call(response)
      new(response).call
    end

    attr_reader :response

    def initialize(response)
      @response = response # XXX dup?
    end

    def call
      message = response_has_error_message? ? response.body : status_message
      raise handle_status, message
    end

    def status_message
      [response.status, response.reason].join(' ')
    end

    def server_error?
      response.status >= 500
    end

    def handle_status
      send("handle_#{response.status}")
    rescue NoMethodError
      server_error? ? handle_server_error : handle_default
    end

    def handle_server_error
      ServerError
    end

    def handle_default
      Error
    end

    def handle_404
      NotFoundError
    end

    def response_has_error_message?
      response.plain_text? && response.has_body?
    end
  end

  # class StoreContentErrorHandler < ErrorHandler
  #   def handle_400
  #     InvalidContentIDError
  #   end

  #   def handle_409
  #     ChecksumError
  #   end
  # end
end
