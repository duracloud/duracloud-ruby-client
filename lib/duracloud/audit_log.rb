module Duracloud
  class AuditLog

    attr_reader :space_id, :store_id

    def initialize(space_id, store_id = nil)
      @space_id = space_id
      @store_id = store_id
      @response = nil
    end

    def csv(opts = {})
      CSVReader.call(tsv, opts)
    end

    def tsv
      response.body
    end

    def to_s
      tsv
    end

    private

    def response
      @response ||= Client.get_manifest(space_id, **query)
    end

    def query
      { storeID: store_id }
    end

  end
end
