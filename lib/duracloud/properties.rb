require 'hashie'
require 'time'
require 'date'

module Duracloud
  #
  # Encapsulates Duracloud "properties" which are transmitted via HTTP headers.
  #
  # @abstract
  #
  class Properties < Hashie::Mash

    PREFIX = "x-dura-meta-".freeze

    # Space properties
    SPACE = /\A#{PREFIX}space-(count|created)\z/

    # Space ACL headers
    SPACE_ACLS = /\A#{PREFIX}acl-/

    # Copy Content headers
    COPY_CONTENT = /\A#{PREFIX}copy-source(-store)?\z/

    # DuraCloud internal content properties
    INTERNAL = /\A#{PREFIX}content-(mimetype|size|checksum|modified)\z/

    # Properties set by the DuraCloud SyncTool
    SYNCTOOL = /\A#{PREFIX}(creator|(content-file-(created|modified|last-accessed|path)))\z/

    # Is the property valid for this class of properties?
    # @note Subclasses should override this method rather than the `#property?'
    #   instance method.
    # @param prop [String] the property name
    # @return [Boolean]
    def self.property?(prop)
      duracloud_property?(prop)
    end

    # Filter the hash of properties, selecting only the properties valid
    #   for this particular usage (subclass).
    # @param hsh [Hash] the unfiltered properties
    # @return [Hash] the filtered properties
    def self.filter(hsh)
      hsh.select { |k, v| property?(k) }
    end

    # Is the property a (theoretically) valid DuraCloud property?
    # @param prop [String] the property name
    # @return [Boolean]
    def self.duracloud_property?(prop)
      prop.start_with?(PREFIX)
    end

    # Is the property a reserved "internal" DuraCloud property?
    # @param prop [String] the property name
    # @return [Boolean]
    def self.internal_property?(prop)
      INTERNAL =~ prop
    end

    # Is the property a space property?
    # @param prop [String] the property name
    # @return [Boolean]
    def self.space_property?(prop)
      SPACE =~ prop
    end

    # Is the property a space ACL?
    # @param prop [String] the property name
    # @return [Boolean]
    def self.space_acl?(prop)
      SPACE_ACLS =~ prop
    end

    # Is the property used for copying content?
    # @param prop [String] the property name
    # @return [Boolean]
    def self.copy_content_property?(prop)
      COPY_CONTENT =~ prop
    end

    # Is the property valid for this class of properties?
    # @note Subclasses should not override this method, but instead
    #   override the `.property?' class method.
    # @param prop [String] the property name
    # @return [Boolean]
    # @api private
    def property?(prop)
      self.class.property?(prop)
    end

    # Filter the hash of properties, selecting only the properties valid
    #   for this particular usage (subclass).
    # @param hsh [Hash] the unfiltered properties
    # @return [Hash] the filtered properties
    def filter(hsh)
      self.class.filter(hsh)
    end

    # @api private
    def regular_writer(key, value)
      if property?(key)
        super
      else
        raise Error, "#{self.class}: Unrecognized or restricted property \"#{key}\"."
      end
    end

    # @api private
    def convert_key(key)
      force_ascii(duracloud_property!(super))
    end

    # @api private
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

    # Coerce to a DuraCloud property
    def duracloud_property!(prop)
      prop.dup.tap do |p|
        p.gsub!(/_/, '-')
        p.downcase!
        p.prepend(PREFIX) unless self.class.duracloud_property?(p)
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
