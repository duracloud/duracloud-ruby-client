module Duracloud
  RSpec.describe Content do

    let(:url) { "https://example.com/durastore/foo/bar" }

    describe ".find" do
      describe "when it exists" do
        before { stub_request(:head, url) }
        specify {
          expect(Content.find("foo", "bar")).to be_a(Content)
        }
      end
      describe "when it does not exist" do
        before { stub_request(:head, url).to_return(status: 404) }
        specify {
          expect { Content.find("foo", "bar") }.to raise_error(NotFoundError)
        }
      end
    end

    describe ".exist?" do
      subject { Content.exist?("foo", "bar") }
      describe "when it exists" do
        before { stub_request(:head, url) }
        it { is_expected.to be true }
      end
      describe "when it does not exist" do
        before { stub_request(:head, url).to_return(status: 404) }
        it { is_expected.to be false }
      end
    end

    describe "#save" do
      subject { Content.new("foo", "bar") }
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
              stub_request(:put, url).with(body: "Some file content")
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
            stub_request(:put, url).with(body: "Some file content")
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
    end

    describe "#delete" do
      subject { Content.new("foo", "bar") }
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
      before {
        stub_request(:head, url)
          .to_return(status: 200, headers: {'x-dura-meta-creator'=>'testuser'})
      }
      specify {
        pending "A problem with Webmock / HTTPClient?"
        content = Content.find("foo", "bar")
        expect(content.properties.x_dura_meta_creator).to eq('testuser')
      }
    end

  end
end
