require "date"

module Duracloud
  class SpaceProperties < Properties
    def self.property?(prop)
      space_property?(prop)
    end
  end
end
