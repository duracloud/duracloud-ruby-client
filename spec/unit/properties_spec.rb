module Duracloud
  RSpec.describe Properties do

    describe "ignores non-DuraCloud keys" do
      subject { described_class.new("access-control-allow-headers"=>"Content-Type, Authorization", "access-control-allow-methods"=>"GET, POST, PUT, DELETE", "access-control-allow-origin"=>"*", "cache-control"=>"no-cache=\"set-cookie\"", "content-type"=>"application/octet-stream", "date"=>"Wed, 12 Jul 2017 14:52:41 GMT", "expires"=>"0", "pragma"=>"no-cache", "server"=>"Apache-Coyote/1.1", "strict-transport-security"=>"max-age=31536000 ; includeSubDomains", "vary"=>"Accept-Encoding", "x-content-type-options"=>"nosniff", "x-dura-meta-space-count"=>"1000+", "x-dura-meta-space-created"=>"2017-07-06T20:35:39", "x-frame-options"=>"DENY", "x-xss-protection"=>"1; mode=block", "connection"=>"keep-alive") }
      its(:to_h) { is_expected.to eq({"x-dura-meta-space-count"=>"1000+", "x-dura-meta-space-created"=>"2017-07-06T20:35:39"}) }
    end

    describe "preserves original keys" do
      subject { described_class.new("x-dura-meta-acl-foo_bar"=>"READ", "x-dura-meta-acl-group-spam-eggs"=>"WRITE") }
      its(:to_h) { is_expected.to eq({"x-dura-meta-acl-foo_bar"=>"READ", "x-dura-meta-acl-group-spam-eggs"=>"WRITE"}) }
    end

  end
end
