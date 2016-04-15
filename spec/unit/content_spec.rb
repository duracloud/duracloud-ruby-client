module Duracloud
  RSpec.describe Content do

    describe ".find" do
      subject { Content.find(space_id: "foo", id: "bar") }
      before {
        allow_any_instance_of(Content).to receive(:load_properties) { nil }
      }
      it { is_expected.to be_a(Content) }
      its(:url) { is_expected.to eq("foo/bar") }
    end

    describe ".create" do
      let(:body) { "Contents of the file" }
      subject { Content.create(space_id: "foo", id: "bar", body: body) }
      before {
        allow_any_instance_of(Content).to receive(:save) { nil }
      }
      it { is_expected.to be_a(Content) }
      its(:url) { is_expected.to eq("foo/bar") }
    end

    describe "#save" do
    end

    describe "#delete" do
    end

  end
end
