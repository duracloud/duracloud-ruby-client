module Duracloud
  RSpec.describe StorageReports do

    describe ".by_space" do
      subject { described_class.by_space("foo") }
      specify {
        stub_request(:get, "https://example.com/durastore/report/space/foo")
          .to_return(body: '[
  {"timestamp":1312588800000,"accountId":"<account-id>","spaceId":"<space-id>","storeId":"<store-id>","byteCount":1000,"objectCount":10},
  {"timestamp":1315008000000,"accountId":"<account-id>","spaceId":"<space-id>","storeId":"<store-id>","byteCount":1000,"objectCount":10},
  {"timestamp":1315526400000,"accountId":"<account-id>","spaceId":"<space-id>","storeId":"<store-id>","byteCount":1000,"objectCount":10}
]')
        expect(subject.map(&:timestamp)).to eq [ 1312588800000, 1315008000000, 1315526400000 ]
      }
    end

    describe ".by_store" do
      subject { described_class.by_store }
      specify {
        stub_request(:get, "https://example.com/durastore/report/store")
          .to_return(body: '[
  {"timestamp":1312588800000,"accountId":"<account-id>","storeId":"<store-id>","byteCount":1000,"objectCount":10},
  {"timestamp":1315008000000,"accountId":"<account-id>","storeId":"<store-id>","byteCount":1000,"objectCount":10},
  {"timestamp":1315526400000,"accountId":"<account-id>","storeId":"<store-id>","byteCount":1000,"objectCount":10}
]')
        expect(subject.map(&:timestamp)).to eq [ 1312588800000, 1315008000000, 1315526400000 ]
      }
    end

    describe ".for_all_spaces_in_a_store" do
      subject { described_class.for_all_spaces_in_a_store(1499400000000) }
      specify {
        stub_request(:get, "https://example.com/durastore/report/store/1499400000000")
          .to_return(body: '[
  {"timestamp":1312588800000,"accountId":"<account-id>","spaceId":"<space-id-1>","storeId":"<store-id>","byteCount":1000,"objectCount":10},
  {"timestamp":1315008000000,"accountId":"<account-id>","spaceId":"<space-id-2>","storeId":"<store-id>","byteCount":1000,"objectCount":10},
  {"timestamp":1315526400000,"accountId":"<account-id>","spaceId":"<space-id-3>","storeId":"<store-id>","byteCount":1000,"objectCount":10}
]')
        expect(subject.map(&:timestamp)).to eq [ 1312588800000, 1315008000000, 1315526400000 ]
      }
    end


  end
end
