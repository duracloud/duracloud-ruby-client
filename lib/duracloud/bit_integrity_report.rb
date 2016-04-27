require "date"
require "csv"

module Duracloud
  class BitIntegrityReport

    SUCCESS = "SUCCESS".freeze
    FAILURE = "FAILURE".freeze

    CSV_OPTS = {
      col_sep: '\t',
      headers: :first_row,
      write_headers: true,
      return_headers: true,
    }

    def self.success?(space_id)
      new(space_id).success?
    end

    attr_reader :space_id

    def initialize(space_id)
      @space_id = space_id
    end

    def data
      report.body
    end

    def completion_date
      DateTime.parse(properties["Bit-Integrity-Report-Completion-Date"].first)
    end

    def result
      properties["Bit-Integrity-Report-Result"].first
    end

    def csv(opts = {})
      CSV.new(data, CSV_OPTS.merge(opts))
    end

    def success?
      result == SUCCESS
    end

    private

    def report
      @report ||= Client.get_bit_integrity_report(space_id)
    end

    def properties
      @properties ||= if @report
                        report.headers
                      else
                        response = Client.get_bit_integrity_report_properties(space_id)
                        response.headers
                      end
    end

  end
end
