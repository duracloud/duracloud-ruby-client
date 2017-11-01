module Duracloud
  RSpec.describe CLI do

    subject { described_class.new(*opts) }

    describe "find item" do
      let(:opts) { %w(find -s foo -c bar) }
      specify {
        stub = stub_request(:head, "https://example.com/durastore/foo/bar")
        expect(Commands::FindItem).to receive(:call).with(subject).and_call_original
        subject.execute
        expect(stub).to have_been_requested
      }
    end

    describe "find space" do
      let(:opts) { %w(find -s foo) }
      specify {
        stub = stub_request(:head, "https://example.com/durastore/foo")
        expect(Commands::FindSpace).to receive(:call).with(subject).and_call_original
        subject.execute
        expect(stub).to have_been_requested
      }
    end

    describe "find items" do
      let(:opts) { %w( find -s foo -f /foo/bar ) }
      specify {
        expect(Commands::FindItems).to receive(:call).with(subject) { nil }
        subject.execute
      }
    end

    describe "count" do
      let(:opts) { %w( count -s foo ) }
      specify {
        stub = stub_request(:head, "https://example.com/durastore/foo")
        expect(Commands::Count).to receive(:call).with(subject).and_call_original
        subject.execute
        expect(stub).to have_been_requested
      }
    end

    describe "sync" do
      let(:opts) { %w( sync -s foo -c bar -f /foo/bar ) }
      specify {
        expect(Commands::Sync).to receive(:call).with(subject) { nil }
        subject.execute
      }
    end

    describe "validate" do
      let(:opts) { %w( validate -s foo -d /tmp ) }
      specify {
        expect(Commands::Validate).to receive(:call).with(subject) { nil }
        subject.execute
      }
    end

    describe "download_manifest" do
      let(:opts) { %w( download_manifest -s foo ) }
      specify {
        expect(Commands::DownloadManifest).to receive(:call).with(subject) { nil }
        subject.execute
      }
    end

    describe "get_storage_report" do
      let(:opts) { %w( get_storage_report -s foo ) }
      specify {
        expect(Commands::GetStorageReport).to receive(:call).with(subject) { nil }
        subject.execute
      }
    end

    describe "list content ids" do
      let(:opts) { %w( list_content_ids -s foo ) }
      specify {
        expect(Commands::ListContentIds).to receive(:call).with(subject) { nil }
        subject.execute
      }
    end

    describe "list items" do
      let(:opts) { %w( list_items -s foo ) }
      specify {
        expect(Commands::ListItems).to receive(:call).with(subject) { nil }
        subject.execute
      }
    end

    describe "store" do
      let(:opts) { %w( store -s foo -c bar -f /foo/bar -t image/jpeg ) }
      specify {
        expect(Commands::StoreContent).to receive(:call).with(subject) { nil }
        subject.execute
      }
    end

  end
end
