module Duracloud::Commands
  class GetStorageReportForAllSpaces < Command

    def call
      Duracloud::StorageReports.for_all_spaces_in_a_store(store_id: store_id).each do |report|
        puts "-"*40
        puts report.to_s
      end
    end

  end
end
