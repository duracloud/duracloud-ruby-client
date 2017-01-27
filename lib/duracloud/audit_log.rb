module Duracloud
  class AuditLog
    include TSV

    attr_reader :space_id, :store_id

    def initialize(space_id, store_id = nil)
      @space_id = space_id
      @store_id = store_id
      @response = nil
    end

    def tsv
      super || response.body
    end

    private

    def response
      @response ||= Client.get_audit_log(space_id, **query)
    end

    def query
      { storeID: store_id }
    end

  end
end
