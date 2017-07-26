module Duracloud
  RSpec.describe CLI do

    subject { described_class.new(**opts) }

    describe "properties" do
      let(:opts) { {space_id: "foo", content_id: "bar"} }
      let(:command) { "properties" }
      specify {
        expect(Commands::GetProperties).to receive(:call).with(subject) { nil }
        subject.execute(command)
      }
    end

    describe "sync" do
      let(:opts) { {space_id: "foo", content_id: "bar", infile: "foo/bar"} }
      let(:command) { "sync" }
      specify {
        expect(Commands::Sync).to receive(:call).with(subject) { nil }
        subject.execute(command)
      }
    end

    describe "validate" do
      let(:opts) { {space_id: "foo", content_dir: "/tmp"} }
      let(:command) { "validate" }
      specify {
        expect(Commands::Validate).to receive(:call).with(subject) { nil }
        subject.execute(command)
      }
    end

    describe "manifest" do
      let(:opts) { {space_id: "foo"} }
      let(:command) { "manifest" }
      specify {
        expect(Commands::DownloadManifest).to receive(:call).with(subject) { nil }
        subject.execute(command)
      }
    end

  end
end
