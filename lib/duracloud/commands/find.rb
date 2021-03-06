module Duracloud::Commands
  class Find < Command

    def call
      delegate_to = if content_id
                      FindItem
                    elsif infile
                      missing ? FindMissingItems : FindItems
                    else
                      FindSpace
                    end
      delegate_to.call(cli)
    end

  end
end
