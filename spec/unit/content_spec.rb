module Duracloud
  RSpec.describe Content do

    describe ".find" do
      subject { Content.find(url: "foo/bar") }
      before {
        allow_any_instance_of(Content).to receive(:load_properties) { nil }
      }
      it { is_expected.to be_a(Content) }
      its(:url) { is_expected.to eq("foo/bar") }
      describe "invalid options" do
        specify {
          expect { Content.find }.to raise_error(ArgumentError)
          expect { Content.find(url: nil) }.to raise_error(ArgumentError)
          expect { Content.find(url: "") }.to raise_error(ArgumentError)
          expect { Content.find(space_id: "foo") }.to raise_error(ArgumentError)
          expect { Content.find(space_id: "foo", content_id: nil) }.to raise_error(ArgumentError)
          expect { Content.find(space_id: "foo", content_id: "") }.to raise_error(ArgumentError)
          expect { Content.find(content_id: "foo") }.to raise_error(ArgumentError)
          expect { Content.find(content_id: "foo", space_id: nil) }.to raise_error(ArgumentError)
          expect { Content.find(content_id: "foo", space_id: "") }.to raise_error(ArgumentError)
        }
      end
    end

    describe ".create" do
      let(:body) { "Contents of the file" }
      subject { Content.create(url: "foo/bar", body: body) }
      before {
        allow_any_instance_of(Content).to receive(:save) { nil }
      }
      it { is_expected.to be_a(Content) }
      its(:url) { is_expected.to eq("foo/bar") }
      describe "invalid options" do
        specify {
          expect { Content.create(body: body) }.to raise_error(ArgumentError)
          expect { Content.create(body: body, space_id: "foo") }.to raise_error(ArgumentError)
          expect { Content.create(body: body, space_id: "foo", content_id: nil) }
            .to raise_error(ArgumentError)
          expect { Content.create(body: body, space_id: "foo", content_id: "") }
            .to raise_error(ArgumentError)
          expect { Content.create(body: body, content_id: "foo") }
            .to raise_error(ArgumentError)
          expect { Content.create(body: body, content_id: "foo", space_id: nil) }
            .to raise_error(ArgumentError)
          expect { Content.create(body: body, content_id: "foo", space_id: "") }
            .to raise_error(ArgumentError)
        }
      end
    end

    describe ".new" do
      describe "invalid options" do
        specify {
          expect { Content.new }.to raise_error(ArgumentError)
          expect { Content.new(space_id: "foo") }.to raise_error(ArgumentError)
          expect { Content.new(space_id: "foo", content_id: nil) }.to raise_error(ArgumentError)
          expect { Content.new(space_id: "foo", content_id: "") }.to raise_error(ArgumentError)
          expect { Content.new(content_id: "foo") }.to raise_error(ArgumentError)
          expect { Content.new(content_id: "foo", space_id: nil) }.to raise_error(ArgumentError)
          expect { Content.new(content_id: "foo", space_id: "") }.to raise_error(ArgumentError)
        }
      end
    end

    describe "#save" do
    end

    describe "#delete" do
    end

  end
end
