require "nokogiri"

module Duracloud
  class Store

    def self.all
      response = Client.get_stores
      doc = Nokogiri::XML(response.body)
      doc.css('storageAcct').map { |acct| new(acct) }
    end

    attr_reader :id, :owner_id, :primary, :provider_type

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
