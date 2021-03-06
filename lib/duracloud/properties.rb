require 'hashie'
require 'time'
require 'date'

module Duracloud
  #
  # Encapsulates Duracloud "properties" which are transmitted via HTTP headers.
  #
  class Properties < Hashie::Mash

    PREFIX = "x-dura-meta-".freeze

    # Is the property name valid?
    # @param prop [String] the property name
    # @return [Boolean]
    def self.property?(prop)
      prop.to_s.start_with?(PREFIX)
    end

    def initialize(source = nil, default = nil, &block)
      source.select! { |k, v| property?(k) } if source
      super
    end

    def property?(prop)
      self.class.property?(prop)
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
