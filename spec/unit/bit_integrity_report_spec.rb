require 'support/shared_examples_for_tsv'

module Duracloud
  RSpec.describe BitIntegrityReport do

    subject { described_class.new("myspace") }

    let(:path) { File.expand_path('../../fixtures/bit_integrity_report.tsv', __FILE__) }

    it_behaves_like "a TSV"

    describe "#csv" do
      before do
        allow(subject).to receive(:tsv) { File.read(path) }
        subject.csv.read
      end
      specify {
        expect(subject.csv.headers).to eq(%w(date_checked account store_id store_type space_id content_id result content_checksum provider_checksum manifest_checksum details))
        expect(subject.rows.to_a.size).to eq(3)
        expect(subject.rows.first).to eq({"date_checked"=>"2016-05-15T04:11:14", "account"=>"example", "store_id"=>"1065", "store_type"=>"AMAZON_S3", "space_id"=>"myspace", "content_id"=>"BINARIES/00/00/e8/0000e819ac3e67d039d288adaab5b5e44c3c21d9", "result"=>"SUCCESS", "content_checksum"=>"27333f3c06a6d259863384799be68d30", "provider_checksum"=>"27333f3c06a6d259863384799be68d30", "manifest_checksum"=>"27333f3c06a6d259863384799be68d30", "details"=>"--"})
      }
    end

  end
end
