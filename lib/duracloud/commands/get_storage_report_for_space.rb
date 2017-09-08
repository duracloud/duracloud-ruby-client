module Duracloud::Commands
  class GetStorageReportForSpace < Command

    def call
      reports = Duracloud::StorageReports.by_space(space_id, store_id: store_id)
      puts reports.last.to_s
    end

  end
end
