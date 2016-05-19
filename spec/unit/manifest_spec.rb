module Duracloud
  RSpec.describe Manifest do

    let(:tsv) { File.read(File.join(File.expand_path('../../fixtures/manifest.tsv', __FILE__))) }

    before {
      allow(subject).to receive(:tsv) { tsv }
    }

    subject { described_class.new("myspace") }

    describe "CSV" do
      specify {
        expect(subject.csv.headers).to eq(%w(space_id content_id md5))
        expect(subject.csv.size).to eq(4)
        expect(subject.csv.to_s.split("\n").first).to eq("space_id,content_id,md5")
        expect(subject.rows.next).to eq({"space_id"=>"myspace", "content_id"=>"METADATA/d6/42/0c/9c/d6420c9c-82f8-4f6a-baf7-37b9be7f4c5f/20160502_172925/manifest-md5.txt", "md5"=>"21fef474787860ccfb67bdd99ddee93a"})
      }
    end

  end
end
