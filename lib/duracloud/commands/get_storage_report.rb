require_relative "command"

module Duracloud::Commands
  class GetStorageReport < Command

    def call
      reports = if space_id
                  Duracloud::StorageReports.by_space(space_id, store_id: store_id)
                else
                  Duracloud::StorageReports.by_store(store_id: store_id)
                end
      report = reports.last
      puts report.to_s
    end

  end
end
