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
        }
        it { is_expected.to be_a(Space) }
        its(:space_id) { is_expected.to eq("foo") }
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

    describe "#acls"

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
        stub_request(:head, url)
          .to_return(headers: {
                       'x-dura-meta-space-count'=>'3',
                       'x-dura-meta-space-created'=>'2016-04-05T17:59:11'
                     })
        stub_request(:get, url).to_return(body: body)
      }
      describe ".content_ids", pending: "Correcting the stub request" do
        subject { Space.content_ids("foo") }
        its(:to_a) { is_expected.to eq(["foo1", "foo2", "foo3"]) }
      end
      describe "#content_ids" do
        subject { Space.find("foo") }
        specify {
          pending "Correcting the stub request"
          expect(subject.content_ids.to_a).to eq(["foo1", "foo2", "foo3"])
        }
      end

      describe ".items"
      describe "#items"

      describe ".count"
      describe "#count"
    end

    describe ".audit_log"
    describe "#audit_log"

    describe ".bit_integrity_report"
    describe "#bit_integrity_report"

    describe ".manifest"
    describe "#manifest"

  end
end
