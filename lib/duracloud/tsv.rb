require "csv"

module Duracloud
  module TSV

    def csv
      @csv ||= CSV.new(tsv, csv_options)
    end

    def rows
      @rows ||= Enumerator.new do |e|
        table.each { |row| e << row.to_hash }
      end
    end

    def table
      csv.rewind
      csv.read
    ensure
      csv.rewind
    end

    def tsv
      @tsv
    end

    def load_tsv(io_or_str)
      @tsv = io_or_str
    end

    def load_tsv_file(path)
      load_tsv(File.new(path, "rb"))
    end

    def to_s
      tsv.to_s
    end

    private

    def csv_options
      { col_sep: "\t",
        quote_char: "`",
        headers: true,
        header_converters: header_converters,
      }
    end

    def header_converters
      lambda { |h| h.downcase.gsub(/-/, "_") }
    end

  end
end
