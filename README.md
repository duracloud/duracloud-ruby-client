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
 => #<Duracloud::Client:0x007fe953a1c630 @config=#<Duracloud::Configuration host="foo.duracloud.org", port=nil, user="bob@example.com", password="******">>
 ```

#### Logging

By default, `Duracloud::Client` logs to `STDERR`.  Use the `logger` config setting to change:

```ruby
Duracloud::Client.configure do |config|
  config.logger = Rails.logger
end
```

### List Storage Providers

```
> stores = Duracloud::Store.all
 => [#<Duracloud::Store:0x007faa592e9068 @owner_id="0", @primary="0", @id="1", @provider_type="AMAZON_GLACIER">, #<Duracloud::Store:0x007faa592dbd78 @owner_id="0", @primary="1", @id="2", @provider_type="AMAZON_S3">]

> stores.first.primary?
 => false 
```

### Space Methods

TODO

### Content Methods

#### Create a new content item and store it in DuraCloud

1. Initialize instance of `Duracloud::Content` and save:

```
>> new_content = Duracloud::Content.new(space_id: "rest-api-testing", id: "ark:/99999/fk4zzzz")
 => #<Duracloud::Content space_id="rest-api-testing", id="ark:/99999/fk4zzzz">
 
>> new_content.body = "test"
 => "test"

>> new_content.content_type = "text/plain"
 => "text/plain"
 
>> new_content.save
 => #<Duracloud::Content space_id="rest-api-testing", id="ark:/99999/fk4zzzz">
```

2. Create with class method `Duracloud::Content.create`:

```
>> Duracloud::Content.create(space_id: "rest-api-testing", id="ark:/99999/fk4zzzz") do |c|
     c.body = "test"
     c.content_type = "text/plain"
   end
 => #<Duracloud::Content space_id="rest-api-testing", id="ark:/99999/fk4zzzz">
```

#### Retrieve an existing content item from DuraCloud

```ruby
Duracloud::Content.find(id: "contentID", space_id: "spaceID") 
```

#### Update the properties for an item

TODO

#### Delete a content item

TODO

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
