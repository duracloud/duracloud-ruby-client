require "csv"

module Duracloud
  class Manifest

    CSV_OPTS = {
      col_sep: '\t',
      headers: :first_row,
      write_headers: true,
      return_headers: true,
    }

    def self.csv(space_id, csv_opts: {})
      data = raw(space_id)
      CSV.new(data, CSV_OPTS.merge(csv_opts))
    end

    def self.raw(space_id)
      response = Client.get_manifest(space_id)
      response.body
    end

  end
end
