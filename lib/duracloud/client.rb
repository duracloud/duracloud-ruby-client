module Duracloud
  class Client
    extend RestMethods
    include RestMethods

    def self.execute(http_method, url, **options, &block)
      new.execute(http_method, url, **options, &block)
    end

    def execute(http_method, url, **options, &block)
      Request.execute(http_method, url, **options, &block).tap do |response|
        ResponseHandler.call(response)
      end
    end

  end
end
