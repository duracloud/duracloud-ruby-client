require 'json'
require 'hashie'

module Duracloud
  class StorageReports
    include Enumerable
    extend Forwardable

    delegate :last => :to_a

    attr_reader :data

    def self.by_space(space_id, **query)
      params = Params.new(query)
      response = Client.get_storage_reports_by_space(space_id, **params)
      new(response)
    end

    def self.by_store(**query)
      params = Params.new(query)
      response = Client.get_storage_reports_by_store(**params)
      new(response)
    end

    def self.for_all_spaces_in_a_store(epoch_ms = nil, **query)
      epoch_ms ||= Time.now.to_i * 1000
      params = Params.new(query)
      response = Client.get_storage_reports_for_all_spaces_in_a_store(epoch_ms, **params)
      new(response)
    end

    def initialize(response)
      @data = JSON.parse(response.body)
    end

    def each
      data.each do |report|
        yield StorageReport.new(report)
      end
    end

    private

    class Params < Hashie::Trash
      property :storeID, from: :store_id
      property :groupBy, from: :group_by
      property :start
      property :end
    end

  end
end
