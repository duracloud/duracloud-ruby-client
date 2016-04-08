module Duracloud
  class Configuration
    class << self
      attr_accessor :host, :port, :user, :password
    end

    attr_reader :host, :port, :user, :password

    def initialize(host: nil, port: nil, user: nil, password: nil)
      @host     = host     || default(:host)
      @port     = port     || default(:port)
      @user     = user     || default(:user)
      @password = password || default(:password)
      freeze
    end

    def base_url
      URI::HTTPS.build(host: host, port: port)
    end

    private

    def default(attr)
      self.class.send(attr) || ENV["DURACLOUD_#{attr.to_s.upcase}"]
    end

    def inspect
      "#<#{self.class} host=#{host.inspect}, port=#{port.inspect}, user=#{user.inspect}, password=\"******\">"
    end
  end
end
