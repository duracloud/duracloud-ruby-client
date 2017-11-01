require 'logger'
require 'uri'
require 'duracloud/version'
require 'duracloud/error'

module Duracloud

  autoload :AbstractEntity, "duracloud/abstract_entity"
  autoload :AuditLog, "duracloud/audit_log"
  autoload :BitIntegrityReport, "duracloud/bit_integrity_report"
  autoload :ChunkedContent, "duracloud/chunked_content"
  autoload :Client, "duracloud/client"
  autoload :CLI, "duracloud/cli"
  autoload :CommandOptions, "duracloud/command_options"
  autoload :Commands, "duracloud/commands"
  autoload :Content, "duracloud/content"
  autoload :ContentManifest, "duracloud/content_manifest"
  autoload :FastSyncValidation, "duracloud/fast_sync_validation"
  autoload :Manifest, "duracloud/manifest"
  autoload :Properties, "duracloud/properties"
  autoload :Request, "duracloud/request"
  autoload :Response, "duracloud/response"
  autoload :ResponseHandler, "duracloud/response_handler"
  autoload :RestMethods, "duracloud/rest_methods"
  autoload :Space, "duracloud/space"
  autoload :SpaceAcls, "duracloud/space_acls"
  autoload :StorageReport, "duracloud/storage_report"
  autoload :StorageReports, "duracloud/storage_reports"
  autoload :Store, "duracloud/store"
  autoload :SyncValidation, "duracloud/sync_validation"
  autoload :TSV, "duracloud/tsv"

  class << self
    attr_accessor :host, :port, :user, :password
    attr_writer :logger

    def logger
      @logger ||= Logger.new(STDERR)
    end

    def silence_logging!
      self.logger = Logger.new(File::NULL)
    end

    def base_url
      URI::HTTPS.build(host: host, port: port, path: '/')
    end

    def auth?
      !!user
    end
  end

  self.host = ENV["DURACLOUD_HOST"]
  self.port = ENV["DURACLOUD_PORT"]
  self.user = ENV["DURACLOUD_USER"]
  self.password = ENV["DURACLOUD_PASSWORD"]

end
