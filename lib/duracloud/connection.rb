require 'httpclient'

module Duracloud
  #
  # An HTTP connection to DuraCloud.
  #
  # @note We are using HTTPClient because Net::HTTP capitalizes
  # request header names which is incompatible with DuraCloud's
  # custom case-sensitive content property headers (x-dura-meta-*).
  #
  class Connection < HTTPClient
    # class << self
    #   attr_accessor :base_path
    # end

    # self.base_path = '/'

    def initialize(client, base_path = '/')
      base_url = client.base_url + base_path
      super(base_url: base_url, force_basic_auth: true)
      set_auth(client.base_url, client.user, client.password)
    end
  end

  # class DurastoreConnection < Connection
  #   self.base_path = '/durastore/'
  # end
end
