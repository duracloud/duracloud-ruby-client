module Duracloud
  RSpec.describe CLI do

    subject { described_class.new(**opts) }

    describe "find item" do
      let(:opts) { {command: "find", space_id: "foo", content_id: "bar"} }
      specify {
        expect(Commands::FindItem).to receive(:call).with(subject) { nil }
        subject.execute
      }
    end

    describe "find space" do
      let(:opts) { {command: "find", space_id: "foo"} }
      specify {
        expect(Commands::FindSpace).to receive(:call).with(subject) { nil }
        subject.execute
      }
    end

    describe "find items" do
      let(:opts) { {command: "find", space_id: "foo", infile: "/foo/bar"} }
      specify {
        expect(Commands::FindItems).to receive(:call).with(subject) { nil }
        subject.execute
      }
    end

    describe "count" do
      let(:opts) { {command: "count", space_id: "foo"} }
      specify {
        expect(Commands::Count).to receive(:call).with(subject) { nil }
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

    describe "download_manifest" do
      let(:opts) { {command: "download_manifest", space_id: "foo"} }
      specify {
        expect(Commands::DownloadManifest).to receive(:call).with(subject) { nil }
        subject.execute
      }
    end

    describe "get_storage_report" do
      let(:opts) { {command: "get_storage_report", space_id: "foo"} }
      specify {
        expect(Commands::GetStorageReport).to receive(:call).with(subject) { nil }
        subject.execute
      }
    end

    describe "list content ids" do
      let(:opts) { {command: "list_content_ids", space_id: "foo"} }
      specify {
        expect(Commands::ListContentIds).to receive(:call).with(subject) { nil }
        subject.execute
      }
    end

    describe "list items" do
      let(:opts) { {command: "list_items", space_id: "foo"} }
      specify {
        expect(Commands::ListItems).to receive(:call).with(subject) { nil }
        subject.execute
      }
    end

  end
end
