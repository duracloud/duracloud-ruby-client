module Duracloud
  module RestMethods

    def get_stores
      durastore(:get, "stores")
    end

    def get_spaces(**query)
      durastore(:get, "spaces", **query)
    end

    def get_space(space_id, **query)
      durastore(:get, space_id, **query)
    end

    def get_space_properties(space_id, **query)
      durastore(:head, space_id, **query)
    end

    def get_space_acls(space_id, **query)
      durastore(:head, "acl/#{space_id}", **query)
    end

    def set_space_acls(space_id, **options)
      durastore(:post, "acl/#{space_id}", **options)
    end

    def create_space(space_id, **query)
      durastore(:put, space_id, **query)
    end

    def delete_space(space_id, **query)
      durastore(:delete, space_id, **query)
    end

    def get_content(space_id, content_id, **options)
      durastore_content(:get, space_id, content_id, **options)
    end

    def get_content_properties(space_id, content_id, **options)
      durastore_content(:head, space_id, content_id, **options)
    end

    def set_content_properties(space_id, content_id, **options)
      durastore_content(:post, space_id, content_id, **options)
    end

    def store_content(space_id, content_id, **options)
      durastore_content(:put, space_id, content_id, **options)
    end

    def copy_content(target_space_id, target_content_id, **options)
      durastore_content(:put, target_space_id, target_content_id, **options)
    end

    def delete_content(space_id, content_id, **options)
      durastore_content(:delete, space_id, content_id, **options)
    end

    def get_audit_log(space_id, **query)
      durastore(:get, "audit/#{space_id}", **query)
    end

    def get_manifest(space_id, **query)
      durastore(:get, "manifest/#{space_id}", **query)
    end

    def get_bit_integrity_report(space_id, **query)
      durastore(:get, "bit-integrity/#{space_id}", **query)
    end

    def get_bit_integrity_report_properties(space_id, **query)
      durastore(:head, "bit-integrity/#{space_id}", **query)
    end

    def get_tasks(**query)
      raise NotImplementedError,
            "The API method 'Get Tasks' has not been implemented."
    end

    def perform_task(task_name, **query)
      raise NotImplementedError,
            "The API method 'Perform Task' has not been implemented."
    end

    private

    def durastore(*args)
      execute(DurastoreRequest, *args)
    end

    def durastore_content(http_method, space_id, content_id, **options)
      escaped_content_id = content_id.gsub(/%/, "%25").gsub(/ /, "%20")
      url = [ space_id, escaped_content_id ].join("/")
      durastore(http_method, url, **options)
    end

  end
end
