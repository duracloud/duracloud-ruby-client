require "csv"

module Duracloud
  module TSV

    CHUNK_SIZE = 1024 * 16

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

    def tsv(&block)
      return unless tsv_source?
      begin
        tsv_source.rewind
        if block_given?
          while chunk = tsv_source.read(CHUNK_SIZE)
            yield chunk
          end
        else
          tsv_source.read
        end
      ensure
        tsv_source.rewind
      end
    end

    def load_tsv(io_or_str)
      @tsv_source = io_or_str.is_a?(String) ? StringIO.new(io_or_str, "rb") : io_or_str
    end

    def tsv_source
      @tsv_source
    end

    def tsv_source?
      !!@tsv_source
    end

    def load_tsv_file(path)
      load_tsv File.new(path, "rb")
    end

    def to_s
      tsv.to_s
    end

    private

    def csv_options
      { col_sep: "\t",
        quote_char: "`",
        headers: true,
        return_headers: false,
        header_converters: header_converters,
      }
    end

    def header_converters
      lambda { |h| h.downcase.gsub(/-/, "_") }
    end

  end
end
