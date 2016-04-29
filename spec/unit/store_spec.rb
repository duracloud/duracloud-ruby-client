module Duracloud
  RSpec.describe Store do

    let(:url) { "https://example.com/durastore/stores" }

    let(:body) { <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<storageProviderAccounts>
  <storageAcct ownerId="0" isPrimary="0">
    <id>1</id>
    <storageProviderType>AMAZON_GLACIER</storageProviderType>
  </storageAcct>
  <storageAcct ownerId="0" isPrimary="1">
    <id>2</id>
    <storageProviderType>AMAZON_S3</storageProviderType>
  </storageAcct>
</storageProviderAccounts>
EOS
    }

    before {
      stub_request(:get, url).to_return(body: body)
    }

    describe ".all" do
      subject { Store.all }
      specify {
        expect(subject.map(&:provider_type)).to contain_exactly("AMAZON_GLACIER", "AMAZON_S3")
      }
    end

    describe ".primary" do
      subject { Store.primary }
      specify {
        expect(subject.id).to eq("2")
      }
    end

  end
end
