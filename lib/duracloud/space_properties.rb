require "date"
require "duracloud/properties"

module Duracloud
  class SpaceProperties < Properties

    def self.property?(prop)
      space?(prop)
    end

    def count
      x_dura_meta_space_count.to_i
    end

    def created
      DateTime.parse(x_dura_meta_space_created)
    end

  end
end
