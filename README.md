# duracloud-ruby-client
Ruby client for communicating with DuraCloud

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'duracloud'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install duracloud

## Usage

### Configure the client

Option 1. Environment variables

    DURACLOUD_HOST
    DURACLOUD_PORT
    DURACLOUD_USER
    DURACLOUD_PASSWORD

Option 2. Manual configuration

```ruby
Duracloud::Client.configure do |config|
  config.host = "foo.duracloud.org"
  config.user = "bob@example.com"
  config.password = "s3cret"
end
```

```
> c = Duracloud::Client.new
 => #<Duracloud::Client:0x007fe953a1c630 @config=#<Duracloud::Configuration host="foo.duracloud.org", port=nil, user="bob@example.com">>
 ```

#### Logging

By default, `Duracloud::Client` logs to `STDERR`.  Use the `logger` config setting to change:

```ruby
Duracloud::Client.configure do |config|
  config.logger = Rails.logger
end
```

You can also silence logging:

```ruby
Duracloud::Client.configure do |config|
  config.silence_logging! # sets logger device to null device
end
```

### List Storage Providers

```
>> stores = Duracloud::Store.all
 => [#<Duracloud::Store:0x007faa592e9068 @owner_id="0", @primary="0", @id="1", @provider_type="AMAZON_GLACIER">, #<Duracloud::Store:0x007faa592dbd78 @owner_id="0", @primary="1", @id="2", @provider_type="AMAZON_S3">]

>> stores.first.primary?
 => false

>> Duracloud::Store.primary
 => #<Duracloud::Store:0x007faa592dbd78 @owner_id="0", @primary="1", @id="2", @provider_type="AMAZON_S3">
```

### Spaces

#### Create a new space

```
>> space = Duracloud::Space.create("rest-api-testing2")
D, [2016-04-29T12:12:32.641574 #28275] DEBUG -- : Duracloud::Client PUT https://foo.duracloud.org/durastore/rest-api-testing2 201 Created
 => #<Duracloud::Space space_id="rest-api-testing2", store_id="(default)"> 
```

A `Duracloud::BadRequestError` is raise if the space ID is invalid (illegal characters, too long, etc.).

#### Retrieve a space and view its properties

```
>> space = Duracloud::Space.find("rest-api-testing")
D, [2016-04-29T12:15:12.593075 #28275] DEBUG -- : Duracloud::Client HEAD https://foo.duracloud.org/durastore/rest-api-testing 200 OK
 => #<Duracloud::Space space_id="rest-api-testing", store_id="(default)">
 
>> space.count
 => 8

>> space.created
 => #<DateTime: 2016-04-05T17:59:11+00:00 ((2457484j,64751s,0n),+0s,2299161j)> 
```

A `Duracloud::NotFoundError` exception is raise if the space does not exist.

#### Enumerate the content IDs of the space

```
>> space.content_ids.each { |id| puts id }
ark:/99999/fk4zzzz
foo
foo2
foo22
foo3
foo5
foo7
foo8
 => nil

>> space.content_ids.to_a
 => ["ark:/99999/fk4zzzz", "foo", "foo2", "foo22", "foo3", "foo5", "foo7", "foo8"] 
```

### Content

#### Create a new content item and store it in DuraCloud

```
>> new_content = Duracloud::Content.new("rest-api-testing", "ark:/99999/fk4zzzz")
 => #<Duracloud::Content space_id="rest-api-testing", content_id="ark:/99999/fk4zzzz", store_id=(default)>
 
>> new_content.body = "test"
 => "test"

>> new_content.content_type = "text/plain"
 => "text/plain"
 
>> new_content.save
 => #<Duracloud::Content space_id="rest-api-testing", content_id="ark:/99999/fk4zzzz", store_id=(default)>
```

When storing content a `Duracloud::NotFoundError` is raised if the space does not exist. A `Duracloud::BadRequestError` is raised if the content ID is invalid.

#### Retrieve an existing content item from DuraCloud

```
>> Duracloud::Content.find("spaceID", "contentID")
 => #<Duracloud::Content space_id="spaceID", content_id="contentID", store_id=(default)>
```

If the space or content ID does not exist, a `Duracloud::NotFoundError` is raised.

#### Update the properties for a content item

```
>> space = Duracloud::Space.find("rest-api-testing")
 => #<Duracloud::Space space_id="rest-api-testing", store_id="(default)">

>> content = space.find_content("foo3")
D, [2016-04-29T18:31:16.975749 #32379] DEBUG -- : Duracloud::Client HEAD https://foo.duracloud.org/durastore/rest-api-testing/foo3 200 OK
 => #<Duracloud::Content space_id="rest-api-testing", content_id="foo3", store_id=(default)>

>> content.properties
 => #<Duracloud::ContentProperties x-dura-meta-owner="ellen@example.com">

>> content.properties.creator = "bob@example.com"
>> content.save
D, [2016-04-29T18:31:52.770195 #32379] DEBUG -- : Duracloud::Client POST https://foo.duracloud.org/durastore/rest-api-testing/foo3 200 OK
I, [2016-04-29T18:31:52.770293 #32379]  INFO -- : Content foo3 updated successfully
 => true

>> content.properties.creator
D, [2016-04-29T18:32:06.465928 #32379] DEBUG -- : Duracloud::Client HEAD https://foo.duracloud.org/durastore/rest-api-testing/foo3 200 OK
 => "bob@example.com"
```     

#### Delete a content item

```
>> space = Duracloud::Space.find("rest-api-testing")
 => #<Duracloud::Space space_id="rest-api-testing", store_id="(default)">

>> content = space.find_content("foo2")
 => #<Duracloud::Content space_id="rest-api-testing", content_id="foo2", store_id=(default)>

>> content.delete
D, [2016-04-29T18:28:31.459962 #32379] DEBUG -- : Duracloud::Client DELETE https://foo.duracloud.org/durastore/rest-api-testing/foo2 200 OK
I, [2016-04-29T18:28:31.460069 #32379]  INFO -- : Content foo2 deleted successfully
 => #<Duracloud::Content space_id="rest-api-testing", content_id="foo2", store_id=(default)>

>> Duracloud::Content.exist?("rest-api-testing", "foo2")
D, [2016-04-29T18:29:03.935451 #32379] DEBUG -- : Duracloud::Client HEAD https://foo.duracloud.org/durastore/rest-api-testing/foo2 404 Not Found
 => false
```

## Versioning

We endeavor to follow semantic versioning.  In particular, versions < 1.0 may introduce backward-incompatible changes without notice.  Use at your own risk.  Version 1.0 signals a stable API.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/duracloud-ruby-client/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Maintainers

* [David Chandek-Stark](https://github.com/dchandekstark) (Duke University)
