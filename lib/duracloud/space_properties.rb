require "date"

module Duracloud
  class SpaceProperties < Properties

    def self.property?(prop)
      space_property?(prop)
    end

    def count
      space_count.to_i
    end

    def created
      DateTime.parse(space_created)
    rescue ArgumentError
      space_created
    end

  end
end
