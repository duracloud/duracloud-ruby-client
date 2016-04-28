module Duracloud
  class ContentProperties < Properties
    def self.property?(prop)
      super && !( space_property?(prop) || space_acl?(prop) || copy_content_property?(prop) )
    end
  end
end
