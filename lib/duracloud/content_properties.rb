require "duracloud/properties"

module Duracloud
  class ContentProperties < Properties

    def self.property?(prop)
      super && !( space?(prop) || space_acl?(prop) || copy_content?(prop) )
    end

  end
end
