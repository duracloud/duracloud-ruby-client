module Duracloud
  class Error < ::StandardError; end
  class ServerError < Error; end
  class NotFoundError < Error; end
  class BadRequestError < Error; end
  class ConflictError < Error; end
  class MessageDigestError < Error; end
  class CommandError < Error; end
end
