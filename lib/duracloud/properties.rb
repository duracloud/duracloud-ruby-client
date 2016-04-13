require 'hashie'

module Duracloud
  class Properties < Hashie::Mash

    PREFIX = "x-dura-meta-".freeze

    ENCODING = Encoding::US_ASCII

    # Space properties
    SPACE = /\A#{PREFIX}space-(count|created)\z/

    # Space ACL headers
    SPACE_ACLS = /\A#{PREFIX}acl-/

    # Copy Content headers
    COPY_CONTENT = /\A#{PREFIX}copy-source(-store)\z/

    # DuraCloud internal content properties
    INTERNAL = /\A#{PREFIX}content-(mimetype|size|checksum|modified)\z/

    # Properties set by the DuraCloud SyncTool
    SYNCTOOL = /\A#{PREFIX}(creator|(content-file-(created|modified|last-accessed-path)))\z/

    def self.filter(hsh)
      hsh.select { |k, v| property?(k) }
    end

    def self.property?(prop)
      ( /\A#{PREFIX}/ =~ prop ) && ( INTERNAL !~ prop )
    end

    def regular_writer(key, value)
      if self.class.property?(key)
        super
      else
        raise Error, "#{self.class}: Unrecognized or restricted property \"#{key}\"."
      end
    end

    def convert_key(key)
      super
        .dup
        .gsub(/_/, '-')
        .downcase
        .force_encoding(ENCODING)
    end

    def convert_value(value, _ = nil)
      if value.is_a?(Array)
        value.map { |v| convert_value(v) }
      else
        value.force_encoding(ENCODING)
      end
    end

    # def changed?
    #   !!@changed
    # end

    # def update(other)
    #   super self.class.filter(other)
    # end

    # def replace(other)
    #   super self.class.filter(other)
    # end

    # private

    # def changed!
    #   @changed = true
    # end

  end
end
