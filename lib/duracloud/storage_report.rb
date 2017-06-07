require 'hashie'
require 'active_support'

module Duracloud
  class StorageReport < Hashie::Trash

    property "space_id",     from: "spaceId"
    property "store_id",     from: "storeId"
    property "byte_count",   from: "byteCount"
    property "object_count", from: "objectCount"
    property "account_id",   from: "accountId"
    property "timestamp"

    def time
      @time ||= Time.at(timestamp / 1000.0).utc
    end

    def human_size
      ActiveSupport::NumberHelper.number_to_human_size(byte_count, prefix: :si)
    end

    def to_s
      <<-EOS
Date:       #{time}
Space ID:   #{space_id || "(all)"}
Store ID:   #{store_id}
Objects:    #{object_count}
Total size: #{human_size} (#{byte_count} bytes)
      EOS
    end

  end
end
