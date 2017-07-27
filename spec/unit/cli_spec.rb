module Duracloud
  RSpec.describe CLI do

    subject { described_class.new(**opts) }

    describe "properties" do
      let(:opts) { {command: "properties", space_id: "foo", content_id: "bar"} }
      specify {
        expect(Commands::GetProperties).to receive(:call).with(subject) { nil }
        subject.execute
      }
    end

    describe "sync" do
      let(:opts) { {command: "sync", space_id: "foo", content_id: "bar", infile: "foo/bar"} }
      specify {
        expect(Commands::Sync).to receive(:call).with(subject) { nil }
        subject.execute
      }
    end

    describe "validate" do
      let(:opts) { {command: "validate", space_id: "foo", content_dir: "/tmp"} }
      specify {
        expect(Commands::Validate).to receive(:call).with(subject) { nil }
        subject.execute
      }
    end

    describe "manifest" do
      let(:opts) { {command: "manifest", space_id: "foo"} }
      specify {
        expect(Commands::DownloadManifest).to receive(:call).with(subject) { nil }
        subject.execute
      }
    end

    describe "storage" do
      let(:opts) { {command: "storage", space_id: "foo"} }
      specify {
        expect(Commands::GetStorageReport).to receive(:call).with(subject) { nil }
        subject.execute
      }
    end

  end
end
