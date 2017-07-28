require 'delegate'

module Duracloud::Commands
  class Command < SimpleDelegator

    def self.call(cli)
      new(cli).call
    end

  end
end
