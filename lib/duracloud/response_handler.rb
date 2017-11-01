module Duracloud
  class ResponseHandler

    def self.call(response)
      new(response).call
    end

    attr_reader :response

    def initialize(response)
      @response = response
    end

    def call
      handle_error
      log_response
    end

    def log_response
      if loggable_response_body?
        Duracloud.logger.info(response.body)
      end
    end

    def loggable_response_body?
      %w(POST PUT DELETE).include?(response.request_method) &&
        response.plain_text? &&
        response.has_body?
    end

    def handle_error
      if response.error?
        raise exception, error_message
      end
    end

    def error_message
      if response.plain_text? && response.has_body?
        response.body
      else
        [ response.status, response.reason ].join(' ')
      end
    end

    def exception
      case response.status
      when 400
        BadRequestError
      when 404
        NotFoundError
      when 409
        ConflictError
      else
        if response.status >= 500
          ServerError
        else
          Error
        end
      end
    end

  end
end
