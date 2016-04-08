require 'hashie'

module Duracloud
  #
  # [See https://groups.google.com/d/msg/duracloud-users/67ONTkAqyCM/SGVOOHTvAAAJ]
  #
  # These are used as part of the REST call to perform a copy
  #
  #   x-dura-meta-copy-source
  #   x-dura-meta-copy-source-store
  #
  # These are used to provide details about a space.
  # You could probably set them on a content item, but that would be a little odd:
  #
  #   x-dura-meta-space-count
  #   x-dura-meta-space-created
  #
  # These are use used as part of the REST call to set space access control
  # (the * is replaced by the user or group name)
  #
  #   x-dura-meta-acl-*
  #   x-dura-meta-acl-group-*
  #
  # These are used for some internal DuraCloud data wrangling,
  # I'd recommend that you not use them in your code:
  #
  #   x-dura-meta-content-mimetype
  #   x-dura-meta-content-size
  #   x-dura-meta-content-checksum
  #   x-dura-meta-content-modified
  #
  # That's it for the exceptions.
  #
  # One other set I'll call out is the values which are captured by the DuraCloud SyncTool.
  # These are added automatically by the SyncTool, so you may have an interest in reading
  # or updating them. Either way, it's good to be aware of them so you don't accidentally
  # step on the values being captured for you.
  #
  #   x-dura-meta-creator
  #   x-dura-meta-content-file-created
  #   x-dura-meta-content-file-modified
  #   x-dura-meta-content-file-last-accessed
  #   x-dura-meta-content-file-path
  #
  # A few other notes:
  #
  # Stick with US-ASCII characters for property names and values
  # There is a 2 KB total size limit on all user-metadata (this includes the metadata
  # we create for you and that you add yourself)
  #
  # Both of these restrictions are put in place by Amazon S3, so we don't have much say
  # in the matter.
  #
  class ContentProperties < Hashie::Mash
    include Hashie::Extensions::Coercion

    PREFIX = "x-dura-meta-".freeze

    ENCODING = Encoding::US_ASCII

    RESERVED = [
      /\Ax-dura-meta-acl-/,
      /\Ax-dura-meta-space-(count|created)\z/,
      /\Ax-dura-meta-copy-source(-store)\z/,
      /\Ax-dura-meta-content-(mimetype|size|checksum|modified)\z/,
    ]

    coerce_value Array, ->(v) { v.first }

    class << self
      attr_accessor :ignore_reserved

      def property?(prop)
        prop.start_with?(PREFIX)
      end
    end

    self.ignore_reserved = true

    def ignore_reserved?
      self.class.ignore_reserved
    end

    def regular_writer(key, value)
      if reserved?(key)
        if ignore_reserved?
          warn "#{self.class}: Ignoring reserved content property \"#{key}\"."
        else
          raise Error, "#{self.class}: The content property \"#{key}\" is reserved."
        end
      else
        super
      end
    end

    def convert_key(key)
      converted = super.dup
      converted.gsub!(/_/, '-')
      converted.downcase!
      converted.prepend(PREFIX) unless self.class.property?(converted)
      converted.force_encoding(ENCODING)
    end

    def reserved?(key)
      RESERVED.any? { |k| k.match(key) }
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
