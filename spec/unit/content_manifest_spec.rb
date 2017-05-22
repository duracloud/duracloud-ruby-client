module Duracloud
  RSpec.describe ContentManifest do

    describe "source" do
      let(:manifest) { described_class.new(space_id: 'foo', manifest_id: 'bar') }
      subject { manifest.source }
      before do
        allow(manifest).to receive(:xml) { File.read(File.expand_path("../../fixtures/content_manifest.xml", __FILE__)) }
      end
      its(:md5) { is_expected.to eq "164e9aee34c0c42915716e11d5d539b5" }
      its(:size) { is_expected.to eq 4227858432 }
      its(:content_type) { is_expected.to eq "application/octet-stream" }
      its(:content_id) { is_expected.to eq "datastreamStore/8/b/d4/info%3Afedora%2Fduke%3A447146%2Fcontent%2Fcontent.0" }
    end

  end
end
