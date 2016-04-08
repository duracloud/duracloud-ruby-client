require "digest"

module Duracloud
  class RequestOptions

    attr_reader :payload, :content_type, :md5, :properties, :query

    def initialize(**options)
      @payload      = options.delete(:payload)
      @content_type = options.delete(:content_type)
      @md5          = options.delete(:md5)
      @properties   = options.delete(:properties)
      @query        = options.delete(:query) { |k| Hash.new }.merge(options)
    end

    def headers
      Hash.new.tap do |h|
        h["Content-MD5"] = md5 if md5
        h["Content-Type"] = content_type if content_type
        h.update(properties) if properties
      end
    end

  end
end
