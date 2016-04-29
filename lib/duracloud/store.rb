require "nokogiri"

module Duracloud
  #
  # A Duracloud storage provider account.
  #
  class Store

   # @return [Array<Duracloud::Store>] the list of available storage provider accounts.
    def self.all
      response = Client.get_stores
      doc = Nokogiri::XML(response.body)
      doc.css('storageAcct').map { |acct| new(acct) }
    end

    # @return [Duracloud::Store] the primary storage provider account.
    def self.primary
      all.detect { |store| store.primary? }
    end

    private_class_method :new

    attr_reader :id, :owner_id, :primary, :provider_type

    # @api private
    def initialize(xml_node)
      @owner_id = xml_node['ownerId']
      @primary = xml_node['isPrimary']
      @id = xml_node.css('id').text
      @provider_type = xml_node.css('storageProviderType').text
    end

    def primary?
      primary == "1"
    end

  end
end
