require 'hashie'

module Duracloud
  # @abstract
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

    def self.inherited(subclass)
      subclass.class_eval do
        include Hashie::Extensions::Coercion

        # Hashie coercions are not inherited
        coerce_value Array, ->(v) { v.first }
      end
    end

    def self.filter(hsh)
      hsh.select { |k, v| property?(k) }
    end

    def self.internal?(prop)
      INTERNAL =~ prop
    end

    def self.space?(prop)
      SPACE =~ prop
    end

    def self.space_acl?(prop)
      SPACE_ACLS =~ prop
    end

    def self.copy_content?(prop)
      COPY_CONTENT =~ prop
    end

    def self.property?(prop)
      prop.start_with?(PREFIX) && !internal?(prop)
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

  end
end
