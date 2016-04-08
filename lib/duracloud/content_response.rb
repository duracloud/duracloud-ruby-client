module Duracloud
  class ContentResponse < Response
    def content
      @content ||= Content.from_response(self)
    end

    def properties
      content.properties
    end
  end
end
