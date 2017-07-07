require 'hashie'
require 'time'
require 'date'

module Duracloud
  #
  # Encapsulates Duracloud "properties" which are transmitted via HTTP headers.
  #
  class Properties < Hashie::Mash
    include Hashie::Extensions::IgnoreUndeclared

    PREFIX = "x-dura-meta-".freeze
    PREFIX_RE = /\A#{PREFIX}/i

    # Is the property name valid?
    # @param prop [String] the property name
    # @return [Boolean]
    def self.property?(prop)
      !!( PREFIX_RE =~ prop )
    end

    def property?(prop)
      self.class.property?(prop)
    end

    # @api private
    def convert_key(key)
      force_ascii(key.to_s.gsub(/_/, '-').downcase)
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
