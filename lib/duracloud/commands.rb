module Duracloud
  module Commands

    def find(cli)
      Find.call(cli)
    end

    def count(cli)
      Count.call(cli)
    end

    def get_storage_report(cli)
      GetStorageReport.call(cli)
    end

    def sync(cli)
      Sync.call(cli)
    end

    def validate(cli)
      Validate.call(cli)
    end

    def download_manifest(cli)
      DownloadManifest.call(cli)
    end

    def list_content_ids(cli)
      ListContentIds.call(cli)
    end

    def list_items(cli)
      ListItems.call(cli)
    end

  end
end

require 'duracloud/commands/command'
Dir[File.expand_path("../commands/*.rb", __FILE__)].each { |m| require m }
