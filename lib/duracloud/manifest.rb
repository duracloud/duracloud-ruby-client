module Duracloud
  class Manifest

    BAGIT = "BAGIT".freeze
    TSV   = "TSV".freeze

    attr_reader :space_id, :store_id

    def initialize(space_id, store_id = nil)
      @space_id = space_id
      @store_id = store_id
      @tsv_response = nil
      @bagit_response = nil
    end

    def csv(opts = {})
      CSVReader.call(tsv, opts)
    end

    def tsv
      tsv_response.body
    end

    def bagit
      bagit_response.body
    end

    private

    def tsv_response
      @tsv_response ||= get_response(TSV)
    end

    def bagit_response
      @bagit_response ||= get_response(BAGIT)
    end

    def get_response(format)
      Client.get_manifest(space_id, query(format))
    end

    def query(format)
      { storeID: store_id, format: format }
    end

  end
end
