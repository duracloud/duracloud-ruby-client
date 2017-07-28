require_relative "command"

module Duracloud::Commands
  class Validate < Command

    def call
      Duracloud::SyncValidation.call(space_id: space_id, store_id: store_id, content_dir: content_dir, work_dir: work_dir)
    end

  end
end
