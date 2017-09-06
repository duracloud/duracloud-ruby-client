module Duracloud::Commands
  class Count < Command

    def call
      space = Duracloud::Space.find(space_id, store_id)
      count = if prefix || space.count == 1000
                space.content_ids(prefix: prefix).to_a.length
              else
                space.count
              end
      puts count
    end

  end
end
