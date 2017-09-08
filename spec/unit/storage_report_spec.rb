module Duracloud
  RSpec.describe StorageReport do

    subject { described_class.new("timestamp"=>1312588800000,"accountId"=>"account1","spaceId"=>"space1","storeId"=>"store1","byteCount"=>1000,"objectCount"=>10) }

    its(:space_id) { is_expected.to eq "space1" }
    its(:store_id) { is_expected.to eq "store1" }
    its(:account_id) { is_expected.to eq "account1" }
    its(:byte_count) { is_expected.to eq 1000 }
    its(:object_count) { is_expected.to eq 10 }
    its(:timestamp) { is_expected.to eq 1312588800000 }
    its(:time) { is_expected.to eq Time.at(1312588800000 / 1000.0) }

  end
end
