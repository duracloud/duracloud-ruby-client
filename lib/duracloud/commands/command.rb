require 'delegate'

module Duracloud::Commands
  class Command < SimpleDelegator

    def self.call(command)
      new(command).call
    end

  end
end
