module Duracloud
  class Manifest
    include TSV

    TSV_FORMAT = "TSV"
    BAGIT_FORMAT = "BAGIT"

    attr_reader :space_id, :store_id

    def initialize(space_id, store_id = nil)
      @space_id = space_id
      @store_id = store_id
    end

    # Returns the manifest in TSV format,
    #   downloading from DuraCloud is not pre-loaded.
    # @yield [String] chunk of the manifest, if block given.
    # @return [Duracloud::Response, String, IO] the response,
    #   if downloaded, or the pre-loaded TSV.
    # @raise [Duracloud::NotFoundError]
    def tsv(&block)
      tsv_source? ? super : download(TSV_FORMAT, &block)
    end

    # Downloads the manifest in BAGIT format.
    # @yield [String] chunk of the manifest, if block given.
    # @return [Duracloud::Response] the response.
    # @raise [Duracloud::NotFoundError]
    def bagit(&block)
      download(BAGIT_FORMAT, &block)
    end

    # Downloads the manifest
    # @yield [String] chunk of the manifest, if block given.
    # @param format [Symbol, String] the format of the manifest.
    #    Defaults to "TSV".
    # @return [Duracloud::Response, String] the response, if block
    #   given, or the manifest content, if no block.
    # @raise [Duracloud::NotFoundError]
    def download(format = TSV_FORMAT, &block)
      fmt = format.to_s.upcase
      if block_given?
        get_response(fmt, &block)
      else
        get_response(fmt).body
      end
    end

    private

    def get_response(format, &block)
      Client.get_manifest(space_id, query(format), &block)
    end

    def query(format)
      { storeID: store_id, format: format }
    end

  end
end
