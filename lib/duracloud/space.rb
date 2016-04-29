require "date"
require "nokogiri"
require "forwardable"

module Duracloud
  #
  # A "space" within a DuraCloud account.
  #
  class Space
    extend Forwardable
    include Persistence
    include HasProperties

    # Max size of content item list for one request.
    #   This limit is imposed by Duracloud.
    MAX_RESULTS = 1000

    # List all spaces
    # @param store_id [String] the store ID (optional)
    # @return [Array<Duracloud::Space>] the list of spaces
    # @raise [Duracloud::Error] the store was not found
    def self.all(store_id = nil)
      response = Client.get_spaces(storeID: store_id)
      doc = Nokogiri::XML(response.body)
      doc.css('space').map { |s| new(s['id'], store_id) }
    end

    # Create a new space
    # @see .new for arguments
    # @return [Duracloud::Space] the space
    # @raise [Duracloud::BadRequestError] the space ID is invalid.
    def self.create(*args)
      new(*args) do |space|
        yield space if block_given?
        space.save
      end
    end

    # Does the space exist?
    # @see .new for arguments
    # @return [Boolean] whether the space exists.
    def self.exist?(*args)
      find(*args) && true
    rescue NotFoundError
      false
    end

    # Find a space
    # @see .new for arguments
    # @return [Duracloud::Space] the space
    # @raise [Duracloud::NotFoundError] the space or store was not found
    def self.find(*args)
      new(*args) do |space|
        space.load_properties
      end
    end

    attr_reader :space_id, :store_id
    alias_method :id, :space_id

    delegate [:count, :created] => :properties

    after_save :reset_acls
    before_delete :reset_acls

    # @param space_id [String] the space ID
    # @param store_id [String] the store ID (optional)
    def initialize(space_id, store_id = nil)
      @space_id = space_id
      @store_id = store_id
      yield self if block_given?
    end

    def inspect
      "#<#{self.class} space_id=#{space_id.inspect}," \
      " store_id=#{(store_id || '(default)').inspect}>"
    end

    def to_s
      space_id
    end

    def find_content(content_id)
      Content.find(space_id, content_id, store_id)
    end

    def audit_log
      AuditLog.new(space_id, store_id)
    end

    def bit_integrity_report
      BitIntergrityReport.new(space_id, store_id)
    end

    def manifest
      Manifest.new(space_id, store_id)
    end

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
    # @see #each
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

    def reset_acls
      @acls = nil
    end

    def create
      Client.create_space(id, **query)
    end

    def update
      options = { headers: acls.to_h, query: query }
      Client.set_space_acls(id, **options)
    end

    def properties_class
      SpaceProperties
    end

    def get_properties_response
      Client.get_space_properties(id, **query)
    end

    def do_delete
      Client.delete_space(id, **query)
    end

    def do_save
      if persisted?
        update
      else
        create
      end
    end

    def query
      { storeID: store_id }
    end

  end
end
