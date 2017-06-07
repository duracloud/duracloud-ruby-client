require 'support/shared_examples_for_tsv'

module Duracloud
  RSpec.describe Manifest do

    subject { described_class.new("myspace") }

    let(:path) { File.expand_path('../../fixtures/manifest.tsv', __FILE__) }

    it_behaves_like "a TSV"

    describe "#csv" do
      before do
        allow(subject).to receive(:tsv) { File.read(path) }
        subject.csv.read
      end
      specify {
        expect(subject.csv.headers).to eq(%w(space_id content_id md5))
        expect(subject.rows.to_a.size).to eq(3)
        expect(subject.rows.first).to eq({"space_id"=>"myspace", "content_id"=>"METADATA/d6/42/0c/9c/d6420c9c-82f8-4f6a-baf7-37b9be7f4c5f/20160502_172925/manifest-md5.txt", "md5"=>"21fef474787860ccfb67bdd99ddee93a"})
      }
    end

    describe "#generate" do
      before do
        stub_request(:post, "https://example.com/durastore/manifest/myspace?format=TSV")
          .to_return(status: 202,
                     headers: { "Location" => "https://example.com/durastore/x-duracloud-admin/generated-manifests/manifest-myspace_amazon_s3_2017-06-02-18-20-14.txt.gz" })
      end
      specify {
        expect(subject.generate).to eq "https://example.com/durastore/x-duracloud-admin/generated-manifests/manifest-myspace_amazon_s3_2017-06-02-18-20-14.txt.gz"
      }
    end

  end
end
