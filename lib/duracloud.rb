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
    attr_writer :host, :port, :user, :password, :logger

    def logger
      @logger ||= Logger.new(STDERR)
    end

    def silence_logging!
      self.logger = Logger.new(File::NULL)
    end

    def host
      @host ||= ENV["DURACLOUD_HOST"]
    end

    def port
      @port ||= ENV["DURACLOUD_PORT"]
    end

    def user
      @user ||= ENV["DURACLOUD_USER"]
    end

    def password
      @password ||= ENV["DURACLOUD_PASSWORD"]
    end

    def base_url
      URI::HTTPS.build(host: host, port: port, path: '/')
    end

    def auth?
      !!user
    end
  end

end
