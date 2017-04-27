require 'nokogiri'

module Duracloud
  class ContentManifest

    attr_reader :doc

    def initialize(xml)
      @doc = Nokogiri::XML(xml)
    end

    def md5
      doc.css("sourceContent md5").text
    end

    def content_type
      doc.css("sourceContent mimetype").text
    end

    def chunks
      doc.css("chunk")
    end

  end
end
