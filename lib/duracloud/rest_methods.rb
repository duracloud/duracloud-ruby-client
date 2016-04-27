module Duracloud
  module RestMethods

    def get_stores
      durastore :get, "stores"
    end

    def get_spaces
      durastore :get, "spaces"
    end

    def get_space(space_id, query: nil)
      durastore :get, space_id, query: query
    end

    def get_space_properties(space_id)
      durastore :head, space_id
    end

    def get_space_acls(space_id)
      durastore :head, "acl/#{space_id}"
    end

    def set_space_acls(space_id, acls)
      durastore :post, space_id, properties: acls
    end

    def create_space(space_id)
      durastore :put, space_id
    end

    def delete_space(space_id)
      durastore :delete, space_id
    end

    def get_content(url, **options)
      durastore :get, url, **options
    end

    def get_content_properties(url, **options)
      durastore :head, url, **options
    end

    def set_content_properties(url, **options)
      durastore :post, url, **options
    end

    def store_content(url, **options)
      durastore :put, url, **options
    end

    def delete_content(url, **options)
      durastore :delete, url, **options
    end

    def get_audit_log
      durastore :get, "audit/#{space_id}"
    end

    def get_manifest(space_id)
      durastore :get, "manifest/#{space_id}"
    end

    def get_bit_integrity_report(space_id)
      durastore :get, "bit-integrity/#{space_id}"
    end

    def get_bit_integrity_report_properties(space_id)
      durastore :head, "bit-integrity/#{space_id}"
    end

    def get_tasks
      raise NotImplementedError, "The API method 'Get Tasks' has not been implemented."
    end

    def perform_task
      raise NotImplementedError, "The API method 'Perform Task' has not been implemented."
    end

    private

    def durastore(*args)
      execute(DurastoreRequest, *args)
    end

  end
end
