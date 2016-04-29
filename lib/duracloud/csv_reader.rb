require "csv"

module Duracloud
  class CSVReader

    CSV_OPTS = {
      col_sep: '\t',
      headers: :first_row,
      write_headers: true,
      return_headers: true,
    }

    def self.call(data, opts = {})
      CSV.new(data, CSV_OPTS.merge(opts))
    end

  end
end
