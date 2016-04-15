require "delegate"
require "duracloud/properties"

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

    def user
      @user ||= UserAcls.new(self)
    end

    def group
      @group ||= GroupAcls.new(self)
    end

    class UserAcls < SimpleDelegator
      def convert_key(key)
        converted = super
        converted.prepend(PREFIX) unless converted.start_with?(PREFIX)
        converted
      end
    end

    class GroupAcls < SimpleDelegator
      def group_prefix
        PREFIX + "group-"
      end

      def convert_key(key)
        converted = super
        converted.prepend(group_prefix) unless converted.start_with?(group_prefix)
        converted
      end
    end

  end
end
