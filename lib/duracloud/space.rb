require "date"
require "nokogiri"

module Duracloud
  #
  # A "space" within a DuraCloud account.
  #
  class Space < AbstractEntity

    after_save :reset_acls

    # Max size of content item list for one request.
    #   This limit is imposed by Duracloud.
    MAX_RESULTS = 1000

    class << self
      # List all spaces
      # @param store_id [String] the store ID (optional)
      # @return [Array<Duracloud::Space>] the list of spaces
      # @raise [Duracloud::Error] the store was not found
      def all(store_id = nil)
        ids(store_id).map { |id| new(id, store_id) }
      end

      # List all space IDs
      # @param store_id [String] the store ID (optional)
      # @return [Array<String>] the list of space IDs
      # @raise [Duracloud::Error] the store was not found
      def ids(store_id = nil)
        response = Client.get_spaces(storeID: store_id)
        doc = Nokogiri::XML(response.body)
        doc.css('space').map { |s| s['id'] }
      end

      # Enumerates the content IDs in the space.
      # @param space_id [String] the space ID
      # @param store_id [String] the store ID (optional)
      # @param prefix [String] the content ID prefix for filtering (optional)
      # @param start_after [String] the content ID to be used as a "marker".
      #   Listing starts after this ID. (optional)
      # @return [Enumerator] an enumerator.
      # @raise [Duracloud::NotFoundError] the space or store does not exist.
      def content_ids(space_id, store_id: nil, prefix: nil, start_after: nil)
        space = find(space_id, store_id)
        space.content_ids(prefix: prefix, start_after: start_after)
      end

      # Enumerates the content items in the space.
      # @param space_id [String] the space ID
      # @param store_id [String] the store ID (optional)
      # @param prefix [String] the content ID prefix for filtering (optional)
      # @param start_after [String] the content ID to be used as a "marker".
      #   Listing starts after this ID. (optional)
      # @return [Enumerator] an enumerator.
      # @raise [Duracloud::NotFoundError] the space does not exist in Duracloud.
      def items(space_id, store_id: nil, prefix: nil, start_after: nil)
        space = find(space_id, store_id)
        space.items(prefix: prefix, start_after: start_after)
      end

      # Create a new space
      # @see .new for arguments
      # @return [Duracloud::Space] the space
      # @raise [Duracloud::BadRequestError] the space ID is invalid.
      def create(*args)
        new(*args) do |space|
          yield space if block_given?
          space.save
        end
      end

      # Does the space exist?
      # @see .new for arguments
      # @return [Boolean] whether the space exists.
      def exist?(*args)
        find(*args) && true
      rescue NotFoundError
        false
      end

      # Find a space
      # @see .new for arguments
      # @return [Duracloud::Space] the space
      # @raise [Duracloud::NotFoundError] the space or store was not found
      def find(*args)
        new(*args) do |space|
          space.load_properties
        end
      end

      # Return the number of items in the space
      # @return [Fixnum] the number of items
      # @raise [Duracloud::NotFoundError] the space or store was not found
      def count(*args)
        find(*args).count
      end

      # Return the audit log for the space
      # @return [Duracloud::AuditLog] the audit log
      # @raise [Duracloud::NotFoundError] the space or store was not found
      def audit_log(*args)
        find(*args).audit_log
      end

      # Return the bit integrity report for the space
      # @return [Duracloud::BitIntegrityReport] the report
      # @raise [Duracloud::NotFoundError] the space or store was not found
      def bit_integrity_report(*args)
        find(*args).bit_integrity_report
      end

      # Return the manifest for the space
      # @return [Duracloud::Manifest] the manifest
      # @raise [Duracloud::NotFoundError] the space or store was not found
      def manifest(*args)
        find(*args).manifest
      end
    end

    attr_accessor :space_id, :store_id
    alias_method :id, :space_id

    after_save :reset_acls
    before_delete :reset_acls

    # @param space_id [String] the space ID
    # @param store_id [String] the store ID (optional)
    def initialize(space_id, store_id = nil)
      super(space_id: space_id, store_id: store_id)
      yield self if block_given?
    end

    def inspect
      "#<#{self.class} space_id=#{space_id.inspect}," \
      " store_id=#{(store_id || '(default)').inspect}>"
    end

    def to_s
      space_id
    end

    # Return the number of items in the space
    # @return [Fixnum] the number of items
    def count
      properties.space_count.to_i
    end

    # Return the creation date of the space, if persisted, or nil.
    # @return [DateTime] the date
    def created
      if space_created = properties.space_created
        DateTime.parse(space_created)
      end
    end

    # Find a content item in the space
    # @return [Duracloud::Content] the content item.
    # @raise [Duracloud::NotFoundError] if the content item does not exist.
    def find_content(content_id)
      Content.find(space_id: space_id, content_id: content_id, store_id: store_id)
    end

    # Return the audit log for the space
    # @return [Duracloud::AuditLog] the audit log
    def audit_log
      AuditLog.new(space_id, store_id)
    end

    # Return the bit integrity report for the space
    # @return [Duracloud::BitIntegrityReport] the report
    def bit_integrity_report
      BitIntegrityReport.new(space_id, store_id)
    end

    # Return the manifest for the space
    # @return [Duracloud::Manifest] the manifest
    def manifest
      Manifest.new(space_id, store_id)
    end

    # Return the ACLs for the space
    # @return [Duracloud::SpaceAcls] the ACLs
    def acls
      @acls ||= SpaceAcls.new(self)
    end

    # Enumerates the content IDs in the space.
    # @param prefix [String] the content ID prefix for filtering (optional)
    # @param start_after [String] the content ID to be used as a "marker".
    #   Listing starts after this ID. (optional)
    # @return [Enumerator] an enumerator.
    # @raise [Duracloud::NotFoundError] the space does not exist in Duracloud.
    def content_ids(prefix: nil, start_after: nil)
      Enumerator.new do |yielder|
        num = 0
        marker = start_after
        while num < count
          q = query.merge(prefix: prefix, maxResults: MAX_RESULTS, marker: marker)
          response = Client.get_space(space_id, **q)
          xml = Nokogiri::XML(response.body)
          ids = xml.css('item').map(&:text)
          break if ids.empty?
          ids.each do |content_id|
            yielder << content_id
          end
          num += ids.length
          marker = ids.last
        end
      end
    end

    # Enumerates the content items in the space.
    # @see #content_ids
    # @return [Enumerator] an enumerator.
    # @raise [Duracloud::NotFoundError] the space does not exist in Duracloud.
    def items(*args)
      Enumerator.new do |yielder|
        content_ids(*args).each do |content_id|
          yielder << find_content(content_id)
        end
      end
    end

    private

    def do_load_properties
      response = Client.get_space_properties(id, **query)
      self.properties = response.headers
    end

    def reset_acls
      @acls = nil
    end

    def create
      Client.create_space(id, **query)
      update unless acls.empty?
    end

    def update
      options = { headers: acls.to_h, query: query }
      Client.set_space_acls(id, **options)
    end

    def properties_class
      SpaceProperties
    end

    def do_delete
      Client.delete_space(id, **query)
    end

    def do_save
      persisted? ? update : create
    end

    def query
      { storeID: store_id }
    end

  end
end
