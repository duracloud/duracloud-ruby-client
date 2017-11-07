module Duracloud
  RSpec.describe Client do
    describe "get_stores" do
      specify {
        stub = stub_request(:get, "https://example.com/durastore/stores")
        subject.get_stores
        expect(stub).to have_been_requested
      }
    end

    describe "get_spaces" do
      it "works without a storeID" do
        stub = stub_request(:get, "https://example.com/durastore/spaces")
        subject.get_spaces
        expect(stub).to have_been_requested
      end
      it "works with a storeID" do
        stub = stub_request(:get, "https://example.com/durastore/spaces")
                           .with(query: {storeID: 1})
        subject.get_spaces(storeID: 1)
        expect(stub).to have_been_requested
      end
    end

    describe "get_space" do
      it "works without a storeID" do
        stub = stub_request(:get, "https://example.com/durastore/foo")
        subject.get_space("foo")
        expect(stub).to have_been_requested
      end
      it "works with a storeID" do
        stub = stub_request(:get, "https://example.com/durastore/foo")
               .with(query: {storeID: 1, prefix: "bar", maxResults: 50, marker: "item1"})
        subject.get_space("foo", storeID: 1, prefix: "bar", maxResults: 50, marker: "item1")
        expect(stub).to have_been_requested
      end
    end

    describe "create_space" do
      it "works without a storeID" do
        stub = stub_request(:put, "https://example.com/durastore/foo")
        subject.create_space("foo")
        expect(stub).to have_been_requested
      end
      it "works with a storeID" do
        stub = stub_request(:put, "https://example.com/durastore/foo")
                           .with(query: {storeID: 1})
        subject.create_space("foo", storeID: 1)
        expect(stub).to have_been_requested
      end
    end

    describe "delete_space" do
      it "works without a storeID" do
        stub = stub_request(:delete, "https://example.com/durastore/foo")
        subject.delete_space("foo")
        expect(stub).to have_been_requested
      end
      it "works with a storeID" do
        stub = stub_request(:delete, "https://example.com/durastore/foo")
                           .with(query: {storeID: 1})
        subject.delete_space("foo", storeID: 1)
        expect(stub).to have_been_requested
      end
    end

    describe "get_space_acls" do
      it "works without a storeID" do
        stub = stub_request(:head, "https://example.com/durastore/acl/foo")
        subject.get_space_acls("foo")
        expect(stub).to have_been_requested
      end
      it "works with a storeID" do
        stub = stub_request(:head, "https://example.com/durastore/acl/foo")
               .with(query: {storeID: 1})
        subject.get_space_acls("foo", storeID: 1)
        expect(stub).to have_been_requested
      end
    end

    describe "set_space_acls" do
      it "works without a storeID" do
        stub = stub_request(:post, "https://example.com/durastore/acl/foo")
               .with(headers: {'x-dura-meta-acl-user0'=>'WRITE',
                               'x-dura-meta-acl-user1'=>'WRITE',
                               'x-dura-meta-acl-group-curators'=>'READ'})
        subject.set_space_acls("foo",
                               headers: {'x-dura-meta-acl-user0'=>'WRITE',
                                         'x-dura-meta-acl-user1'=>'WRITE',
                                         'x-dura-meta-acl-group-curators'=>'READ'})
        expect(stub).to have_been_requested
      end
      it "works with a storeID" do
        stub = stub_request(:post, "https://example.com/durastore/acl/foo")
               .with(headers: {'x-dura-meta-acl-user0'=>'WRITE',
                               'x-dura-meta-acl-user1'=>'WRITE',
                               'x-dura-meta-acl-group-curators'=>'READ'},
                     query: {storeID: 1})
        subject.set_space_acls("foo",
                               storeID: 1,
                               headers: {'x-dura-meta-acl-user0'=>'WRITE',
                                         'x-dura-meta-acl-user1'=>'WRITE',
                                         'x-dura-meta-acl-group-curators'=>'READ'})
        expect(stub).to have_been_requested
      end
    end

    describe "get_content" do
      it "works without a storeID" do
        stub = stub_request(:get, "https://example.com/durastore/foo/bar")
        subject.get_content("foo", "bar")
        expect(stub).to have_been_requested
      end
      it "works with a storeID" do
        stub = stub_request(:get, "https://example.com/durastore/foo/bar")
               .with(query: {storeID: 1})
        subject.get_content("foo", "bar", storeID: 1)
        expect(stub).to have_been_requested
      end
      it "escapes percent and pound signs in the content id" do
        stub = stub_request(:get, "https://example.com/durastore/foo/z/z/bar%252Fbaz%23bang")
        subject.get_content("foo", "z/z/bar%2Fbaz#bang")
        expect(stub).to have_been_requested
      end
    end

    describe "get_content_properties" do
      it "works without a storeID" do
        stub = stub_request(:head, "https://example.com/durastore/foo/bar")
        subject.get_content_properties("foo", "bar")
        expect(stub).to have_been_requested
      end
      it "works with a storeID" do
        stub = stub_request(:head, "https://example.com/durastore/foo/bar")
               .with(query: {storeID: 1})
        subject.get_content_properties("foo", "bar", storeID: 1)
        expect(stub).to have_been_requested
      end
      it "escapes percent and pound signs and spaces in the content id" do
        stub = stub_request(:head, "https://example.com/durastore/foo/z/z/bar%252Fbaz%20spam%20eggs%23bang")
        subject.get_content_properties("foo", "z/z/bar%2Fbaz spam eggs#bang")
        expect(stub).to have_been_requested
      end
    end

    describe "set_content_properties" do
      it "works without a storeID" do
        stub = stub_request(:post, "https://example.com/durastore/foo/bar")
               .with(headers: {'x-dura-meta-owner'=>'testuser'})
        subject.set_content_properties("foo", "bar",
                                       headers: {'x-dura-meta-owner'=>'testuser'})
        expect(stub).to have_been_requested
      end
      it "works with a storeID" do
        stub = stub_request(:post, "https://example.com/durastore/foo/bar")
               .with(headers: {'x-dura-meta-owner'=>'testuser'},
                     query: {storeID: 1})
        subject.set_content_properties("foo", "bar",
                                       headers: {'x-dura-meta-owner'=>'testuser'},
                                       storeID: 1)
        expect(stub).to have_been_requested
      end
      it "escapes percent and pound signs in the content id" do
        stub = stub_request(:post, "https://example.com/durastore/foo/z/z/bar%252Fbaz%23%23bang")
               .with(headers: {'x-dura-meta-owner'=>'testuser'})
        subject.set_content_properties("foo", "z/z/bar%2Fbaz##bang",
                                       headers: {'x-dura-meta-owner'=>'testuser'})
        expect(stub).to have_been_requested
      end
    end

    describe "store_content" do
      it "works without a storeID" do
        stub = stub_request(:put, "https://example.com/durastore/foo/bar")
               .with(body: "File content",
                     headers: {
                       'Content-Type'=>'text/plain',
                       'Content-MD5'=>'8bb2564936980e92ceec8a5759ec34a8'
                     })
        subject.store_content("foo", "bar",
                              body: "File content",
                              headers: {
                                'Content-Type'=>'text/plain',
                                'Content-MD5'=>'8bb2564936980e92ceec8a5759ec34a8'
                              })
        expect(stub).to have_been_requested
      end
      it "works with a storeID" do
        stub = stub_request(:put, "https://example.com/durastore/foo/bar")
               .with(body: "File content",
                     headers: {
                       'Content-Type'=>'text/plain',
                       'Content-MD5'=>'8bb2564936980e92ceec8a5759ec34a8'
                     },
                     query: {storeID: 1})
        subject.store_content("foo", "bar",
                              body: "File content",
                              headers: {
                                'Content-Type'=>'text/plain',
                                'Content-MD5'=>'8bb2564936980e92ceec8a5759ec34a8'
                              },
                              storeID: 1)
        expect(stub).to have_been_requested
      end
      it "escapes percent and pound signs in the content id" do
        stub = stub_request(:put, "https://example.com/durastore/foo/z/z/bar%252Fbaz%23bang")
               .with(body: "File content",
                     headers: {
                       'Content-Type'=>'text/plain',
                       'Content-MD5'=>'8bb2564936980e92ceec8a5759ec34a8'
                     })
        subject.store_content("foo", "z/z/bar%2Fbaz#bang",
                              body: "File content",
                              headers: {
                                'Content-Type'=>'text/plain',
                                'Content-MD5'=>'8bb2564936980e92ceec8a5759ec34a8'
                              })
        expect(stub).to have_been_requested
      end
    end

    describe "delete_content" do
      it "works without a storeID" do
        stub = stub_request(:delete, "https://example.com/durastore/foo/bar")
        subject.delete_content("foo", "bar")
        expect(stub).to have_been_requested
      end
      it "works with a storeID" do
        stub = stub_request(:delete, "https://example.com/durastore/foo/bar")
               .with(query: {storeID: 1})
        subject.delete_content("foo", "bar", storeID: 1)
        expect(stub).to have_been_requested
      end
      it "escapes percent and pound signs in the content id" do
        stub = stub_request(:delete, "https://example.com/durastore/foo/z/z/bar%252Fbaz%23bang")
        subject.delete_content("foo", "z/z/bar%2Fbaz#bang")
        expect(stub).to have_been_requested
      end
    end

    describe "copy_content" do
      specify {
        stub = stub_request(:put, "https://example.com/durastore/spam/eggs")
               .with(headers: {'x-dura-meta-copy-source'=>'foo/bar'})
        subject.copy_content("spam", "eggs", headers: {'x-dura-meta-copy-source'=>'foo/bar'})
        expect(stub).to have_been_requested
      }
    end

    describe "get_audit_log" do
      it "works without a storeID" do
        stub = stub_request(:get, "https://example.com/durastore/audit/foo")
        subject.get_audit_log("foo")
        expect(stub).to have_been_requested
      end
      it "works with a storeID" do
        stub = stub_request(:get, "https://example.com/durastore/audit/foo")
               .with(query: {storeID: 1})
        subject.get_audit_log("foo", storeID: 1)
        expect(stub).to have_been_requested
      end
    end

    describe "get_manifest" do
      it "works without a storeID" do
        stub = stub_request(:get, "https://example.com/durastore/manifest/foo")
        subject.get_manifest("foo")
        expect(stub).to have_been_requested
      end
      it "works with a storeID" do
        stub = stub_request(:get, "https://example.com/durastore/manifest/foo")
               .with(query: {format: "BAGIT", storeID: 1})
        subject.get_manifest("foo", format: "BAGIT", storeID: 1)
        expect(stub).to have_been_requested
      end
    end

    describe "generate_manifest" do
      it "works without a storeID" do
        stub = stub_request(:post, "https://example.com/durastore/manifest/foo")
        subject.generate_manifest("foo")
        expect(stub).to have_been_requested
      end
      it "works with a storeID" do
        stub = stub_request(:post, "https://example.com/durastore/manifest/foo")
               .with(query: {format: "BAGIT", storeID: 1})
        subject.generate_manifest("foo", format: "BAGIT", storeID: 1)
        expect(stub).to have_been_requested
      end
    end

    describe "get_bit_integrity_report" do
      it "works without a storeID" do
        stub = stub_request(:get, "https://example.com/durastore/bit-integrity/foo")
        subject.get_bit_integrity_report("foo")
        expect(stub).to have_been_requested
      end
      it "works with a storeID" do
        stub = stub_request(:get, "https://example.com/durastore/bit-integrity/foo")
               .with(query: {storeID: 1})
        subject.get_bit_integrity_report("foo", storeID: 1)
        expect(stub).to have_been_requested
      end
    end

    describe "get_bit_integrity_report_properties" do
      it "works without a storeID" do
        stub = stub_request(:head, "https://example.com/durastore/bit-integrity/foo")
        subject.get_bit_integrity_report_properties("foo")
        expect(stub).to have_been_requested
      end
      it "works with a storeID" do
        stub = stub_request(:head, "https://example.com/durastore/bit-integrity/foo")
               .with(query: {storeID: 1})
        subject.get_bit_integrity_report_properties("foo", storeID: 1)
        expect(stub).to have_been_requested
      end
    end

    describe "get_tasks" do
      specify {
        expect { subject.get_tasks }.to raise_error(NotImplementedError)
      }
    end

    describe "perform_task" do
      specify {
        expect { subject.perform_task("enable-streaming") }
          .to raise_error(NotImplementedError)
      }
    end

    describe "get_storage_reports_by_space" do
      specify {
        stub = stub_request(:get, "https://example.com/durastore/report/space/foo")
        subject.get_storage_reports_by_space("foo")
        expect(stub).to have_been_requested
      }
    end

    describe "get_storage_reports_by_store" do
      specify {
        stub = stub_request(:get, "https://example.com/durastore/report/store")
        subject.get_storage_reports_by_store
        expect(stub).to have_been_requested
      }
    end

    describe "get_storage_reports_for_all_spaces_in_a_store" do
      specify {
        stub = stub_request(:get, "https://example.com/durastore/report/store/1499400000000")
        subject.get_storage_reports_for_all_spaces_in_a_store(1499400000000)
        expect(stub).to have_been_requested
      }
    end
  end
end
