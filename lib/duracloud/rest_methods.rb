module Duracloud
  module RestMethods

    # @see https://wiki.duraspace.org/display/DURACLOUDDOC/DuraCloud+REST+API#DuraCloudRESTAPI-GetStores
    def get_stores
      durastore(:get, "stores")
    end

    # @see https://wiki.duraspace.org/display/DURACLOUDDOC/DuraCloud+REST+API#DuraCloudRESTAPI-GetSpaces
    def get_spaces(**query)
      durastore(:get, "spaces", **query)
    end

    # @see https://wiki.duraspace.org/display/DURACLOUDDOC/DuraCloud+REST+API#DuraCloudRESTAPI-GetSpace
    def get_space(space_id, **query)
      durastore(:get, space_id, **query)
    end

    # @see https://wiki.duraspace.org/display/DURACLOUDDOC/DuraCloud+REST+API#DuraCloudRESTAPI-GetSpaceProperties
    def get_space_properties(space_id, **query)
      durastore(:head, space_id, **query)
    end

    # @see https://wiki.duraspace.org/display/DURACLOUDDOC/DuraCloud+REST+API#DuraCloudRESTAPI-GetSpaceACLs
    def get_space_acls(space_id, **query)
      durastore(:head, "acl/#{space_id}", **query)
    end

    # @see https://wiki.duraspace.org/display/DURACLOUDDOC/DuraCloud+REST+API#DuraCloudRESTAPI-SetSpaceACLs
    def set_space_acls(space_id, **options)
      durastore(:post, "acl/#{space_id}", **options)
    end

    # @see https://wiki.duraspace.org/display/DURACLOUDDOC/DuraCloud+REST+API#DuraCloudRESTAPI-CreateSpace
    def create_space(space_id, **query)
      durastore(:put, space_id, **query)
    end

    # @see https://wiki.duraspace.org/display/DURACLOUDDOC/DuraCloud+REST+API#DuraCloudRESTAPI-DeleteSpace
    def delete_space(space_id, **query)
      durastore(:delete, space_id, **query)
    end

    # @see https://wiki.duraspace.org/display/DURACLOUDDOC/DuraCloud+REST+API#DuraCloudRESTAPI-GetContent
    def get_content(space_id, content_id, **options, &block)
      durastore_content(:get, space_id, content_id, **options, &block)
    end

    # @see https://wiki.duraspace.org/display/DURACLOUDDOC/DuraCloud+REST+API#DuraCloudRESTAPI-GetContentProperties
    def get_content_properties(space_id, content_id, **options)
      durastore_content(:head, space_id, content_id, **options)
    end

    # @see https://wiki.duraspace.org/display/DURACLOUDDOC/DuraCloud+REST+API#DuraCloudRESTAPI-SetContentProperties
    def set_content_properties(space_id, content_id, **options)
      durastore_content(:post, space_id, content_id, **options)
    end

    # @see https://wiki.duraspace.org/display/DURACLOUDDOC/DuraCloud+REST+API#DuraCloudRESTAPI-StoreContent
    def store_content(space_id, content_id, **options)
      durastore_content(:put, space_id, content_id, **options)
    end

    # @see https://wiki.duraspace.org/display/DURACLOUDDOC/DuraCloud+REST+API#DuraCloudRESTAPI-CopyContent
    def copy_content(target_space_id, target_content_id, **options)
      durastore_content(:put, target_space_id, target_content_id, **options)
    end

    # @see https://wiki.duraspace.org/display/DURACLOUDDOC/DuraCloud+REST+API#DuraCloudRESTAPI-DeleteContent
    def delete_content(space_id, content_id, **options)
      durastore_content(:delete, space_id, content_id, **options)
    end

    # @see https://wiki.duraspace.org/display/DURACLOUDDOC/DuraCloud+REST+API#DuraCloudRESTAPI-GetAuditLog
    def get_audit_log(space_id, **query)
      durastore(:get, "audit/#{space_id}", **query)
    end

    # @see https://wiki.duraspace.org/display/DURACLOUDDOC/DuraCloud+REST+API#DuraCloudRESTAPI-GetManifest
    def get_manifest(space_id, **query, &block)
      durastore(:get, "manifest/#{space_id}", **query, &block)
    end

    # @see https://wiki.duraspace.org/display/DURACLOUDDOC/DuraCloud+REST+API#DuraCloudRESTAPI-GenerateManifest
    def generate_manifest(space_id, **query)
      durastore(:post, "manifest/#{space_id}", **query)
    end

    # @see https://wiki.duraspace.org/display/DURACLOUDDOC/DuraCloud+REST+API#DuraCloudRESTAPI-GetBitIntegrityReport
    def get_bit_integrity_report(space_id, **query)
      durastore(:get, "bit-integrity/#{space_id}", **query)
    end

    # @see https://wiki.duraspace.org/display/DURACLOUDDOC/DuraCloud+REST+API#DuraCloudRESTAPI-GetBitIntegrityReportProperties
    def get_bit_integrity_report_properties(space_id, **query)
      durastore(:head, "bit-integrity/#{space_id}", **query)
    end

    # @see https://wiki.duraspace.org/display/DURACLOUDDOC/DuraCloud+REST+API#DuraCloudRESTAPI-GetTasks
    def get_tasks(**query)
      raise NotImplementedError,
            "The API method 'Get Tasks' has not been implemented."
    end

    # @see https://wiki.duraspace.org/display/DURACLOUDDOC/DuraCloud+REST+API#DuraCloudRESTAPI-PerformTask
    def perform_task(task_name, **query)
      raise NotImplementedError,
            "The API method 'Perform Task' has not been implemented."
    end

    # @see https://wiki.duraspace.org/display/DURACLOUDDOC/DuraCloud+REST+API#DuraCloudRESTAPI-GetStorageReportsbySpace
    def get_storage_reports_by_space(space_id, **query)
      durastore(:get, "report/space/#{space_id}", **query)
    end

    # @see https://wiki.duraspace.org/display/DURACLOUDDOC/DuraCloud+REST+API#DuraCloudRESTAPI-GetStorageReportsbyStore
    def get_storage_reports_by_store(**query)
      durastore(:get, "report/store", **query)
    end

    # @see https://wiki.duraspace.org/display/DURACLOUDDOC/DuraCloud+REST+API#DuraCloudRESTAPI-GetStorageReportsforallSpacesinaStore(inasingleday)
    def get_storage_reports_for_all_spaces_in_a_store(epoch_ms, **query)
      durastore(:get, "report/store/#{epoch_ms}", **query)
    end

    private

    def durastore(http_method, url_path, **options, &block)
      url = [ "durastore", url_path ].join("/")
      execute(http_method, url, **options, &block)
    end

    def escape_content_id(content_id)
      content_id.gsub(/%/, "%25").gsub(/\#/, "%23")
    end

    def durastore_content(http_method, space_id, content_id, **options, &block)
      url = [ space_id, escape_content_id(content_id) ].join("/")
      durastore(http_method, url, **options, &block)
    end

  end
end
