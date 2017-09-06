module Duracloud::Commands
  class CopyContent < Command

    def call
      if content_id
        copy_one(content_id)
      elsif infile
        batch_copy
      end
    end

    private

    def copy_one(source_id)
      content = Duracloud::Content.find(space_id: space_id, content_id: source_id, store_id: store_id)
      if dryrun
        puts "DRYRUN: would copy item '#{source_id}' from '#{space_id}' to '#{to}'."
      else
        content.copy(space_id: to)
        puts "Copied item '#{source_id}' from '#{space_id}' to '#{to}'."
      end
    end

    def batch_copy
      File.foreach(infile) { |line| copy_one(line.chomp) }
    end

  end
end
