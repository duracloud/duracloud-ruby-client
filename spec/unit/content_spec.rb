module Duracloud
  RSpec.describe Content do

    let(:url) { "https://example.com/durastore/foo/bar" }
    let(:manifest_url) { "#{url}.dura-manifest" }

    describe ".find" do
      describe "when it exists" do
        subject { described_class.find(space_id: "foo", content_id: "bar") }
        describe "and it is not chunked" do
          before {
            stub_request(:head, url)
              .to_return(headers: {
                           "Content-MD5"=>"164e9aee34c0c42915716e11d5d539b5",
                           "Content-Length"=>"1811970",
                           "Content-Type"=>"image/jpeg",
                           "Last-Modified"=>"2017-06-12T17:36:58",
                         })
          }
          it { is_expected.to be_a described_class }
          it { is_expected.to_not be_chunked }
          its(:md5) { is_expected.to eq "164e9aee34c0c42915716e11d5d539b5" }
          its(:size) { is_expected.to eq 1811970 }
          its(:content_type) { is_expected.to eq "image/jpeg" }
          its(:modified) { is_expected.to eq DateTime.parse("2017-06-12T17:36:58") }
        end
        describe "and it is chunked" do
          let(:manifest_xml) { File.read(File.expand_path("../../fixtures/content_manifest.xml", __FILE__)) }
          before do
            stub_request(:head, url).to_return(status: 404)
            stub_request(:head, manifest_url)
              .to_return(headers: {
                           "Last-Modified"=>"2017-06-26T16:38:42",
                         })
            stub_request(:get, manifest_url).to_return(body: manifest_xml)
          end
          it { is_expected.to be_a described_class }
          its(:md5) { is_expected.to eq "164e9aee34c0c42915716e11d5d539b5" }
          its(:size) { is_expected.to eq 4227858432 }
          its(:content_type) { is_expected.to eq "application/octet-stream" }
          its(:modified) { is_expected.to eq DateTime.parse("2017-06-26T16:38:42") }
          it { is_expected.to be_chunked }
        end
      end
      describe "when it does not exist" do
        before do
          stub_request(:head, url).to_return(status: 404)
          stub_request(:head, manifest_url).to_return(status: 404)
        end
        specify {
          expect { Content.find(space_id: "foo", content_id: "bar") }.to raise_error(NotFoundError)
        }
      end
      describe "when providing an MD5" do
        before do
          stub_request(:head, url).to_return(headers: {'Content-MD5'=>'foo'})
        end
        describe "that is correct" do
          specify {
            expect(Content.find(space_id: "foo", content_id: "bar", md5: "foo")).to be_a(Content)
          }
        end
        describe "that is incorrect" do
          specify {
            expect { Content.find(space_id: "foo", content_id: "bar", md5: "bar") }.to raise_error(MessageDigestError)
          }
        end
      end
    end

    describe ".exist?" do
      describe "when it exists" do
        describe "and it is not chunked" do
          before { stub_request(:head, url) }
          specify {
            expect(Content.exist?(space_id: "foo", content_id: "bar")).to be true
          }
        end
        describe "and it is chunked" do
          before do
            stub_request(:head, url).to_return(status: 404)
            stub_request(:head, manifest_url)
            stub_request(:get, manifest_url)
          end
          specify {
            expect(Content.exist?(space_id: "foo", content_id: "bar")).to be true
          }
        end
      end
      describe "when it does not exist" do
        before do
          stub_request(:head, url).to_return(status: 404)
          stub_request(:head, manifest_url).to_return(status: 404)
        end
        specify {
          expect(Content.exist?(space_id: "foo", content_id: "bar")).to be false
        }
      end
      describe "when providing an MD5" do
        before do
          stub_request(:head, url).to_return(headers: {'Content-MD5'=>'foo'})
        end
        describe "that is correct" do
          specify {
            expect(Content.exist?(space_id: "foo", content_id: "bar", md5: "foo")).to be true
          }
        end
        describe "that is incorrect" do
          specify {
            expect { Content.exist?(space_id: "foo", content_id: "bar", md5: "bar") }.to raise_error(MessageDigestError)
          }
        end
      end
    end

    describe "#save" do
      subject { Content.new(space_id: "foo", content_id: "bar") }
      describe "when not persisted" do
        describe "when empty" do
          it "raises an exception" do
            expect { subject.save }.to raise_error(Error)
          end
        end
        describe "when not empty" do
          before { subject.body = "Some file content" }
          describe "and the space does not exist" do
            before {
              stub_request(:put, url).with(body: "Some file content")
                .to_return(status: 404)
            }
            it "raises an exception" do
              expect { subject.save }.to raise_error(NotFoundError)
            end
          end
          describe "and the space exists" do
            before do
              stub_request(:put, url)
                .with(body: "Some file content",
                      headers: {"Content-MD5"=>"92bbcf620ceb5f5bf38f08e9a1f31e7b"})
                .to_return(status: 201)
            end
            it "stores the content" do
              subject.save
              expect(subject).to be_persisted
            end
          end
        end
      end
      describe "when persisted" do
        before {
          allow(subject).to receive(:persisted?) { true }
          stub_request(:head, url)
        }
        describe "and the body has changed" do
          before {
            stub_request(:put, url)
              .with(body: "Some file content",
                    headers: {"Content-MD5"=>"92bbcf620ceb5f5bf38f08e9a1f31e7b"})
              .to_return(status: 201)
          }
          it "stores the content" do
            subject.body = "Some file content"
            subject.save
          end
        end
        describe "and the body has not changed" do
          before {
            stub_request(:post, url)
              .with(headers: {'x-dura-meta-creator'=>'testuser'})
          }
          it "updates the properties" do
            subject.properties["x-dura-meta-creator"] = "testuser"
            subject.save
          end
        end
      end
      describe "when the body is a file" do
        let(:path) { File.expand_path('../../fixtures/lorem_ipsum.txt', __FILE__) }
        let(:file) { File.new(path, "rb") }
        before do
          stub_request(:put, url)
            .with(body: File.read(path),
                  headers: {"Content-MD5"=>"039d7100bea9ef2efbe151db953726ce"})
            .to_return(status: 201)
        end
        it "stores the file content" do
          subject.body = file
          subject.save
        end
      end
    end

    describe "#delete" do
      subject { Content.new(space_id: "foo", content_id: "bar") }
      describe "when not found" do
        before { stub_request(:delete, url).to_return(status: 404) }
        it "raises an exception" do
          expect { subject.delete }.to raise_error(NotFoundError)
        end
      end
      describe "when found" do
        before { stub_request(:delete, url) }
        it "deletes the content" do
          subject.delete
          expect(subject).to be_deleted
        end
      end
    end

    describe "#properties" do
      before do
        stub_request(:head, url)
          .to_return(headers: {'x-dura-meta-creator'=>'testuser',
                               'Content-Type'=>'text/plain',
                               'Content-MD5'=>'08a008a01d498c404b0c30852b39d3b8'})
      end
      specify {
        content = Content.find(space_id: "foo", content_id: "bar")
        expect(content.properties["x-dura-meta-creator"]).to eq('testuser')
      }
    end

    describe "#copy" do
      subject { Content.new(space_id: "foo", content_id: "bar", md5: "08a008a01d498c404b0c30852b39d3b8") }
      let(:target) { "https://example.com/durastore/spam/eggs" }
      before do
        stub_request(:put, target)
          .with(headers: {'x-dura-meta-copy-source'=>'foo/bar'})
          .to_return(status: 201,
                     headers: {'Content-MD5'=>'08a008a01d498c404b0c30852b39d3b8'})
        stub_request(:head, target).to_return(status: 404)
        stub_request(:head, "#{target}.dura-manifest").to_return(status: 404)
      end
      specify {
        copied = subject.copy(space_id: "spam", content_id: "eggs")
        expect(copied).to be_a(Content)
      }
      it "defaults target space to current space" do
        target = "https://example.com/durastore/foo/eggs"
        stub1 = stub_request(:put, target)
                .with(headers: {'x-dura-meta-copy-source'=>'foo/bar'})
                .to_return(status: 201,
                           headers: {'Content-MD5'=>'08a008a01d498c404b0c30852b39d3b8'})
        stub2 = stub_request(:head, target).to_return(status: 404)
        stub3 = stub_request(:head, "#{target}.dura-manifest").to_return(status: 404)
        copied = subject.copy(content_id: "eggs")
        expect(copied).to be_a(Content)
        expect(stub1).to have_been_requested
        expect(stub2).to have_been_requested
        expect(stub3).to have_been_requested
      end
      describe "when the target exists" do
        before do
          stub_request(:head, target).to_return(status: 200)
        end
        describe "and force argument is true" do
          it "overwrites the target" do
            expect { subject.copy(space_id: "spam", content_id: "eggs", force: true) }.not_to raise_error
          end
        end
        describe "and force argument is false" do
          it "raises an exception" do
            expect { subject.copy(space_id: "spam", content_id: "eggs", force: false) }.to raise_error(Content::CopyError)
          end
        end
      end
    end

    describe "#move" do
      let(:target) { "https://example.com/durastore/spam/eggs" }
      subject { Content.new(space_id: "foo", content_id: "bar", md5: '08a008a01d498c404b0c30852b39d3b8') }
      describe "when copy succeeds" do
        it "deletes the source" do
          allow(described_class)
            .to receive(:exist?)
                 .with(space_id: "spam", content_id: "eggs", store_id: nil) { false }
          stub1 = stub_request(:put, target)
                  .with(headers: {'x-dura-meta-copy-source'=>'foo/bar'})
                  .to_return(status: 201,
                             headers: {'Content-MD5'=>'08a008a01d498c404b0c30852b39d3b8'})
          stub2 = stub_request(:delete, "https://example.com/durastore/foo/bar")
          moved = subject.move(space_id: "spam", content_id: "eggs")
          expect(moved).to be_a(Content)
          expect(stub1).to have_been_requested
          expect(stub2).to have_been_requested
        end
      end
      describe "when copy fails" do
        it "does not delete the source" do
          allow(subject).to receive(:copy).with(space_id: "spam", content_id: "eggs").and_raise(Content::CopyError)
          expect(subject).not_to receive(:delete)
          expect { subject.move(space_id: "spam", content_id: "eggs") }.to raise_error(Content::CopyError)
        end
      end
      describe "when target exists" do
        before do
          allow(described_class)
            .to receive(:exist?)
                 .with(space_id: "spam", content_id: "eggs", store_id: nil) { true }
          stub_request(:put, target)
            .with(headers: {'x-dura-meta-copy-source'=>'foo/bar'})
            .to_return(status: 201,
                       headers: {'Content-MD5'=>'08a008a01d498c404b0c30852b39d3b8'})
          stub_request(:delete, "https://example.com/durastore/foo/bar")
          stub_request(:head, target).to_return(status: 200)
          allow(Content).to receive(:exist?).with(space_id: "spam", content_id: "eggs") { true }
        end
        describe "and force argument is true" do
          it "overwrites the target" do
            expect(subject).to receive(:copy).and_call_original
            subject.move(space_id: "spam", content_id: "eggs", force: true)
          end
        end
        describe "and force argument is false" do
          it "raises an exception" do
            expect { subject.move(space_id: "spam", content_id: "eggs", force: false) }.to raise_error(Content::CopyError)
          end
        end
      end
    end

  end
end
