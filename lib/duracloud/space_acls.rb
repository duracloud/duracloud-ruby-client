module Duracloud
  class SpaceAcls < Properties

    def self.property?(prop)
      space_acl?(prop)
    end

    attr_reader :space

    def initialize(space)
      super()
      @space = space
      if space.persisted?
        response = Client.get_space_acls(space.id)
        update SpaceAcls.filter(response.headers)
      end
    end

  end
end
