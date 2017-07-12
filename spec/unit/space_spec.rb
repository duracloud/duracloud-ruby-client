module Duracloud
  RSpec.describe Space do

    describe "listings" do
      let(:body) { <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<spaces>
  <space id="space1" />
  <space id="space2" />
</spaces>
EOS
      }
      before {
        stub_request(:get, "https://example.com/durastore/spaces")
          .to_return(body: body)
      }
      describe ".all" do
        specify {
          expect(Space.all.map(&:id)).to eq(["space1", "space2"])
        }
      end
      describe ".ids" do
        specify {
          expect(Space.ids).to eq(["space1", "space2"])
        }
      end
    end

    describe ".create" do
      describe "invalid space ID" do
        before {
          stub_request(:put, "https://example.com/durastore/INVALID")
            .to_return(status: 400)
        }
        specify {
          expect { Space.create("INVALID") }.to raise_error(BadRequestError)
        }
      end
      describe "valid space ID" do
        subject { Space.create("valid") }
        before {
          stub_request(:put, "https://example.com/durastore/valid")
        }
        it { is_expected.to be_a(Space) }
        its(:space_id) { is_expected.to eq("valid") }
      end
    end

    describe ".find" do
      let(:url) { "https://example.com/durastore/foo" }
      subject { Space.find("foo") }
      describe "when found" do
        before {
          stub_request(:head, url)
            .to_return(headers: {
                         "x-dura-meta-space-count"=>"1000+",
                         "x-dura-meta-space-created"=>"2017-05-18T20:03:18",
                       })
        }
        it { is_expected.to be_a(Space) }
        its(:space_id) { is_expected.to eq("foo") }
        its(:count) { is_expected.to eq 1000 }
        its(:created) { is_expected.to eq DateTime.parse("2017-05-18T20:03:18") }
      end
      describe "when not found" do
        before {
          stub_request(:head, url).to_return(status: 404)
        }
        specify {
          expect { subject }.to raise_error(NotFoundError)
        }
      end
    end

    describe ".exist?" do
      let(:url) { "https://example.com/durastore/foo" }
      subject { Space.exist?("foo") }
      describe "when found" do
        before {
          stub_request(:head, url)
        }
        it { is_expected.to be true }
      end
      describe "when not found" do
        before {
          stub_request(:head, url).to_return(status: 404)
        }
        it { is_expected.to be false }
      end
    end

    describe "#save"

    describe "#delete"

    describe "#acls" do
      let(:url) { "https://example.com/durastore/foo" }
      subject { Space.find("foo") }
      before {
        stub_request(:head, url)
        allow(Client).to receive(:get_space_acls)
                          .with("foo", hash_including(storeID: nil)) {
          double(body: "",
                 headers: {
                   'x-dura-meta-acl-bob'=>'READ',
                   'x-dura-meta-acl-group-curators'=>'WRITE'
                 })
        }
      }
      specify {
        expect(subject.acls.to_h)
          .to eq({'x-dura-meta-acl-bob'=>'READ',
                  'x-dura-meta-acl-group-curators'=>'WRITE'})
      }
    end

    describe "contents" do
      let(:body) { <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<space id="rest-api-testing">
  <item>foo1</item>
  <item>foo2</item>
  <item>foo3</item>
</space>
EOS
      }
      let(:url) { "https://example.com/durastore/foo" }
      before {
        stub_request(:head, "#{url}/foo1")
        stub_request(:head, "#{url}/foo2")
        stub_request(:head, "#{url}/foo3")
        stub_request(:get, "#{url}?maxResults=1000")
          .to_return(body: body,
                     headers: {
                       'X-Dura-Meta-Space-Count'=>'3',
                       'X-Dura-Meta-Space-Created'=>'2016-04-05T17:59:11'
                     })
        stub_request(:head, url)
          .to_return(headers: {
                       'x-dura-meta-space-count'=>'3',
                       'x-dura-meta-space-created'=>'2016-04-05T17:59:11'
                     })
      }
      describe "class methods" do
        specify {
          expect(Space.content_ids("foo").to_a).to eq(["foo1", "foo2", "foo3"])
        }
        specify {
          expect(Space.items("foo").map(&:id)).to eq(["foo1", "foo2", "foo3"])
        }
        specify {
          expect(Space.count("foo")).to eq(3)
        }
      end
      describe "instance methods" do
        subject { Space.find("foo") }
        specify {
          expect(subject.content_ids.to_a).to eq(["foo1", "foo2", "foo3"])
        }
        specify {
          expect(subject.items.map(&:id)).to eq(["foo1", "foo2", "foo3"])
        }
        its(:count) { is_expected.to eq(3) }
      end
    end

    describe "reports" do
      describe "class methods" do
        before {
          stub_request(:head, "https://example.com/durastore/foo")
        }
        specify {
          expect(Space.audit_log("foo")).to be_a(AuditLog)
        }
        specify {
          expect(Space.bit_integrity_report("foo")).to be_a(BitIntegrityReport)
        }
        specify {
          expect(Space.manifest("foo")).to be_a(Manifest)
        }
      end
      describe "instance methods" do
        subject { described_class.new("foo") }
        its(:audit_log) { is_expected.to be_a(AuditLog) }
        its(:bit_integrity_report) { is_expected.to be_a(BitIntegrityReport) }
        its(:manifest) { is_expected.to be_a(Manifest) }
      end
    end
  end
end
