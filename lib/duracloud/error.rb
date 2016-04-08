module Duracloud
  class Error < ::StandardError; end
  class ServerError < Error; end
  class NotFoundError < Error; end
  class ChecksumError < Error; end
  class InvalidContentIDError < Error; end
end
