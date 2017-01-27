module Duracloud
  RSpec.describe AuditLog do

    let(:path) { File.expand_path('../../fixtures/audit_log.tsv', __FILE__) }

    subject { described_class.new("myspace") }

    describe "#csv" do
      before {
        allow(subject).to receive(:tsv) { File.read(path) }
        subject.csv.read
      }
      specify {
        expect(subject.csv.headers).to eq(%w(account store_id space_id content_id content_md5 content_size content_mimetype content_properties space_acls source_space_id source_content_id timestamp action username))
        expect(subject.rows.to_a.size).to eq(6)
        expect(subject.rows.first).to eq({"account"=>"example", "store_id"=>"1065", "space_id"=>"myspace", "content_id"=>nil, "content_md5"=>nil, "content_size"=>nil, "content_mimetype"=>nil, "content_properties"=>nil, "space_acls"=>nil, "source_space_id"=>nil, "source_content_id"=>nil, "timestamp"=>"2016-04-27T18:34:18.018", "action"=>"CREATE_SPACE", "username"=>"bob@example.com"})
      }
    end

    describe "#load_tsv" do
      it "loads a string" do
        tsv = File.read(path)
        subject.load_tsv(tsv)
        expect(subject.tsv).to eq(tsv)
      end
      it "loads an IO" do
        tsv = File.read(path)
        tsv_io = File.new(path, "rb")
        subject.load_tsv(tsv)
        expect(subject.tsv.to_s).to eq(tsv)
      end
    end

  end
end
