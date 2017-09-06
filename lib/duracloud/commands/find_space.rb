module Duracloud::Commands
  class FindSpace < Command

    def call
      space = Duracloud::Space.find(space_id, store_id)
      space.properties.each do |k, v|
        puts "#{k}: #{v}"
      end
    end

  end
end
