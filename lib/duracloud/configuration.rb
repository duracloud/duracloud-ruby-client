require "logger"
require "uri"

module Duracloud
  class Configuration

    class << self
      attr_accessor :host, :port, :user, :password, :logger
    end

    attr_reader :host, :port, :user, :password, :logger

    def initialize(host: nil, port: nil, user: nil, password: nil, logger: nil)
      @host     = host     || default(:host)
      @port     = port     || default(:port)
      @user     = user     || default(:user)
      @password = password || default(:password)
      @logger   = logger   || Logger.new(STDERR)
      freeze
    end

    def base_url
      URI::HTTPS.build(host: host, port: port)
    end

    def inspect
      "#<#{self.class} host=#{host.inspect}, port=#{port.inspect}, user=#{user.inspect}," \
      " password=\"******\", logger=#{logger.inspect}>"
    end

    private

    def default(attr)
      self.class.send(attr) || ENV["DURACLOUD_#{attr.to_s.upcase}"]
    end

  end
end
