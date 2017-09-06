module Duracloud::Commands
  class Sync < Command

    def call
      if infile
        File.open(infile, "rb") do |f|
          self.content_id ||= infile # XXX relativize to cwd?
          Duracloud::Content.create(space_id: space_id, store_id: store_id, content_id: content_id, md5: md5, body: f)
        end
      else
        Duracloud::Content.create(space_id: space_id, store_id: store_id, content_id: content_id, md5: md5, body: $stdin)
      end
    end

  end
end
