module Duracloud::Commands
  class DownloadManifest < Command

    def call
      Duracloud::Manifest.download(space_id, store_id, format: format) do |chunk|
        print chunk
      end
    end

  end
end
