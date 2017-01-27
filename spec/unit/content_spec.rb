module Duracloud
  RSpec.describe Content do

    let(:url) { "https://example.com/durastore/foo/bar" }

    describe ".find" do
      describe "when it exists" do
        before { stub_request(:head, url) }
        specify {
          expect(Content.find(space_id: "foo", content_id: "bar")).to be_a(Content)
        }
      end
      describe "when it does not exist" do
        before { stub_request(:head, url).to_return(status: 404) }
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
        before { stub_request(:head, url) }
        specify {
          expect(Content.exist?(space_id: "foo", content_id: "bar")).to be true
        }
      end
      describe "when it does not exist" do
        before { stub_request(:head, url).to_return(status: 404) }
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
            before {
              stub_request(:put, url)
                .with(body: "Some file content",
                      headers: {"Content-MD5"=>"92bbcf620ceb5f5bf38f08e9a1f31e7b"})
                .to_return(status: 201)
            }
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
            allow(subject).to receive(:body_changed?) { false }
            stub_request(:post, url)
              .with(headers: {'x-dura-meta-creator'=>'testuser'})
          }
          it "updates the properties" do
            subject.properties.creator = "testuser"
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
        pending "Research Webmock problem with return headers"
        content = Content.find(space_id: "foo", content_id: "bar")
        expect(content.properties.x_dura_meta_creator).to eq('testuser')
      }
    end

    describe "#copy" do
      subject { Content.new(space_id: "foo", content_id: "bar") }
      specify {
        stub = stub_request(:put, "https://example.com/durastore/spam/eggs")
          .with(headers: {'x-dura-meta-copy-source'=>'foo/bar'})
        subject.copy(target_space_id: "spam", target_content_id: "eggs")
        expect(stub).to have_been_requested
      }
    end

  end
end
