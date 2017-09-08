module Duracloud::Commands
  class GetStorageReport < Command

    def call
      delegate_to = if space_id
                      GetStorageReportForSpace
                    elsif all_spaces
                      GetStorageReportForAllSpaces
                    else
                      GetStorageReportForStore
                    end
      delegate_to.call(cli)
    end

  end
end
