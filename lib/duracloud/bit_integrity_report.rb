require "date"

module Duracloud
  class BitIntegrityReport
    include TSV

    SUCCESS = "SUCCESS".freeze
    FAILURE = "FAILURE".freeze

    COMPLETION_DATE_HEADER = "Bit-Integrity-Report-Completion-Date".freeze
    RESULT_HEADER          = "Bit-Integrity-Report-Result".freeze

    attr_reader :space_id, :store_id

    def initialize(space_id, store_id = nil)
      @space_id = space_id
      @store_id = store_id
      @report, @properties = nil, nil
    end

    def tsv
      report.body
    end

    def completion_date
      DateTime.parse(properties[COMPLETION_DATE_HEADER].first)
    end

    def result
      properties[RESULT_HEADER].first
    end

    def success?
      result == SUCCESS
    end

    def report
      @report ||= fetch_report
    end

    def report_loaded?
      !@report.nil?
    end

    def properties
      @properties ||= fetch_properties
    end

    private

    def fetch_report
      reset_properties
      Client.get_bit_integrity_report(space_id, **query)
    end

    def reset_properties
      @properties = nil
    end

    def fetch_properties
      if report_loaded?
        report.headers
      else
        response = Client.get_bit_integrity_report_properties(space_id, **query)
        response.headers
      end
    end

    def query
      { storeID: store_id }
    end

  end
end
