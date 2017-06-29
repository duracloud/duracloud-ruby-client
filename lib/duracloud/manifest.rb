require 'tempfile'
require 'zlib'

module Duracloud
  class Manifest
    include TSV

    TSV_FORMAT = "TSV"
    BAGIT_FORMAT = "BAGIT"

    MAX_TRIES = 120
    RETRY_SLEEP = 10

    attr_reader :space_id, :store_id

    def self.download(*args, **kwargs, &block)
      new(*args).download(**kwargs, &block)
    end

    def self.download_generated(*args, **kwargs, &block)
      new(*args).download_generated(**kwargs, &block)
    end

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

    # Request the manifest for the space to be generated.
    # @param format [Symbol, String] the format of the manifest.
    #    Defaults to "TSV".
    # @return [String] the URL of the generated manifest when available.
    # @raise [Duracloud::NotFoundError]
    # @note format parameter changed from positional to keyword argument
    #   in v0.5.0.
    def generate(format: TSV_FORMAT)
      fmt = format.to_s.upcase
      response = Client.generate_manifest(space_id, query(fmt))
      response.header["Location"].first
    end

    # Downloads the generated manifest
    # @yield [String] chunk of the manifest
    # @param format [Symbol, String] the format of the manifest.
    #   Defaults to "TSV".
    # @param max_tries [Integer] max number of times to check the generated URL.
    # @param retry_sleep [Integer] number of seconds between re-checks of the
    #   generated URL.
    # @raise [Duracloud::NotFoundError
    def download_generated(format: TSV_FORMAT, max_tries: MAX_TRIES, retry_sleep: RETRY_SLEEP, &block)
      url = generate(format: format)
      check_generated(url, max_tries, retry_sleep)
      Tempfile.open(["download", ".gz"], encoding: "ascii-8bit") do |gz_file|
        client.execute(Request, :get, url) do |chunk|
          gz_file.write(chunk)
        end
        gz_file.close
        Zlib::GzipReader.open(gz_file.path) do |unzipped|
          unzipped.each { |line| yield(line) }
        end
      end
      url
    end

    # Downloads the manifest
    # @yield [String] chunk of the manifest, if block given.
    # @param format [Symbol, String] the format of the manifest.
    #    Defaults to "TSV".
    # @return [Duracloud::Response, String] the response, if block
    #   given, or the manifest content, if no block.
    # @raise [Duracloud::NotFoundError]
    # @note format parameter changed from positional to keyword argument
    #   in v0.5.0.
    def download(format: TSV_FORMAT, &block)
      fmt = format.to_s.upcase
      if block_given?
        get_response(fmt, &block)
      else
        get_response(fmt).body
      end
    end

    private

    def client
      @client ||= Client.new
    end

    def check_generated(url, max_tries, retry_sleep)
      tries = 0
      begin
        tries += 1
        client.logger.debug "Checking for generated manifest (try #{tries}/#{max_tries}) ... "
        client.execute(Request, :head, url)
      rescue NotFoundError => e
        if tries < max_tries
          client.logger.debug "Retrying in #{retry_sleep} seconds ..."
          sleep(retry_sleep)
          retry
        else
          raise
        end
      end
    end

    def get_response(format, &block)
      Client.get_manifest(space_id, query(format), &block)
    end

    def query(format)
      { storeID: store_id, format: format }
    end

  end
end
