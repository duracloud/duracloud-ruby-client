require "csv"

module Duracloud
  module TSV
    # @return [CSV::Table]
    def csv
      @csv ||= CSV::Table.new([]).tap do |csv|
        header_line, rows = tsv.split(/\r?\n/, 2)
        headers = header_line.split("\t").map { |h| h.downcase.gsub(/-/, "_") }
        header_row = CSV::Row.new(headers, headers, true)
        csv << header_row
        rows.split(/\r?\n/).each do |row|
          csv << row.split("\t")
        end
      end
    end

    # @return [Enumerator] rows as hashes
    def rows
      Enumerator.new do |e|
        csv.by_row!.each do |row|
          next if row.header_row?
          e << row.to_hash
        end
      end
    end

    def tsv
      raise NotImplementedError, "Including module must implement `tsv`."
    end
  end
end
