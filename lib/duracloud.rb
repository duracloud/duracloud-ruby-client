require "duracloud/version"
require "duracloud/error"

module Duracloud
  autoload :AbstractEntity, "duracloud/abstract_entity"
  autoload :AuditLog, "duracloud/audit_log"
  autoload :BitIntegrityReport, "duracloud/bit_integrity_report"
  autoload :ChunkedContent, "duracloud/chunked_content"
  autoload :Client, "duracloud/client"
  autoload :Configuration, "duracloud/configuration"
  autoload :Connection, "duracloud/connection"
  autoload :Content, "duracloud/content"
  autoload :ContentManifest, "duracloud/content_manifest"
  autoload :ContentProperties, "duracloud/content_properties"
  autoload :DurastoreRequest, "duracloud/durastore_request"
  autoload :ErrorHandler, "duracloud/error_handler"
  autoload :Manifest, "duracloud/manifest"
  autoload :Properties, "duracloud/properties"
  autoload :Request, "duracloud/request"
  autoload :Response, "duracloud/response"
  autoload :RestMethods, "duracloud/rest_methods"
  autoload :Space, "duracloud/space"
  autoload :SpaceAcls, "duracloud/space_acls"
  autoload :SpaceProperties, "duracloud/space_properties"
  autoload :Store, "duracloud/store"
  autoload :TSV, "duracloud/tsv"
end
