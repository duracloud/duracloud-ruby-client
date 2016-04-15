require 'hashie'
require 'time'
require 'date'

module Duracloud
  # @abstract
  class Properties < Hashie::Mash

    PREFIX = "x-dura-meta-".freeze

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

    def self.property?(prop)
      duraspace_property?(prop) && !internal_property?(prop)
    end

    def self.filter(hsh)
      hsh.select { |k, v| property?(k) }
    end

    def self.duraspace_property?(prop)
      prop.start_with?(PREFIX)
    end

    def self.internal_property?(prop)
      INTERNAL =~ prop
    end

    def self.space_property?(prop)
      SPACE =~ prop
    end

    def self.space_acl?(prop)
      SPACE_ACLS =~ prop
    end

    def self.copy_content_property?(prop)
      COPY_CONTENT =~ prop
    end

    def property?(prop)
      self.class.property?(prop)
    end

    def regular_writer(key, value)
      if property?(key)
        super
      else
        raise Error, "#{self.class}: Unrecognized or restricted property \"#{key}\"."
      end
    end

    def convert_key(key)
      force_ascii(duraspace_property!(super))
    end

    def convert_value(value, _ = nil)
      case value
      when Array
        convert_array(value)
      when Time
        value.utc.iso8601
      when DateTime
        convert_value(value.to_time)
      else
        force_ascii(value.to_s)
      end
    end

    private

    # coerce to a Duraspace property
    def duraspace_property!(prop)
      prop.dup.tap do |p|
        p.gsub!(/_/, '-')
        p.downcase!
        p.prepend(PREFIX) unless self.class.duraspace_property?(p)
      end
    end

    def convert_array(value)
      value.uniq!
      if value.length > 1
        value.map { |v| convert_value(v) }
      else
        convert_value(value.first)
      end
    end

    def force_ascii(str)
      str.ascii_only? ? str : str.force_encoding("US-ASCII")
    end

  end
end
