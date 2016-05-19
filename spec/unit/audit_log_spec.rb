module Duracloud
  RSpec.describe AuditLog do

    let(:tsv) { File.read(File.join(File.expand_path('../../fixtures/audit_log.tsv', __FILE__))) }

    before {
      allow(subject).to receive(:tsv) { tsv }
    }

    subject { described_class.new("myspace") }

    describe "CSV" do
      specify {
        expect(subject.csv.headers).to eq(%w(account store_id space_id content_id content_md5 content_size content_mimetype content_properties space_acls source_space_id source_content_id timestamp action username))
        expect(subject.csv.size).to eq(7)
        expect(subject.csv.to_s.split("\n").first).to eq("account,store_id,space_id,content_id,content_md5,content_size,content_mimetype,content_properties,space_acls,source_space_id,source_content_id,timestamp,action,username")
        expect(subject.rows.next).to eq({"account"=>"example", "store_id"=>"1065", "space_id"=>"myspace", "content_id"=>"", "content_md5"=>"", "content_size"=>"", "content_mimetype"=>"", "content_properties"=>"", "space_acls"=>"", "source_space_id"=>"", "source_content_id"=>"", "timestamp"=>"2016-04-27T18:34:18.018", "action"=>"CREATE_SPACE", "username"=>"bob@example.com"})
      }
    end

  end
end
