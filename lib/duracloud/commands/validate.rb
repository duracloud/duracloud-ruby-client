module Duracloud::Commands
  class Validate < Command

    def call
      klass = fast ? Duracloud::FastSyncValidation : DuracloudSyncValidation
      klass.call(space_id: space_id, store_id: store_id, content_dir: content_dir, work_dir: work_dir)
    end

  end
end
