require_relative "properties"

module Duracloud
  class ContentProperties < Properties

    def self.property?(prop)
      super && (SPACE !~ prop) && (SPACE_ACLS !~ prop) && (COPY_CONTENT !~ prop)
    end

  end
end
