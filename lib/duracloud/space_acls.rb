module Duracloud
  class SpaceAcls < Properties

    READ  = "READ".freeze
    WRITE = "WRITE".freeze

    ACL_PREFIX = (PREFIX + "acl-").freeze

    def self.property?(prop)
      space_acl?(prop)
    end

    attr_reader :space

    def initialize(space)
      super()
      @space = space
      if space.persisted?
        response = Client.get_space_acls(space.space_id, **query)
        update filter(response.headers)
      end
    end

    def query
      { storeID: space.store_id }
    end

    def show
      each_with_object({}) do |(k, v), memo|
        memo[k.sub(ACL_PREFIX, "")] = v
      end
    end

    def grant(perm, to)
      prop = ACL_PREFIX + to
      self[prop] = perm
    end

    def grant_write(to)
      grant WRITE, to
    end

    def grant_read(to)
      grant READ, to
    end

    def revoke(from)
      prop = ACL_PREFIX + from
      delete prop
    end
  end
end
