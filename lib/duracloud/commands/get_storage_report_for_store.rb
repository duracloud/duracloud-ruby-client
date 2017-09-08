module Duracloud::Commands
  class GetStorageReportForStore < Command

    def call
      reports = Duracloud::StorageReports.by_store(store_id: store_id)
      puts reports.last.to_s
    end

  end
end
