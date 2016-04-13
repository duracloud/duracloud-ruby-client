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

### Create a new content item and store it in DuraCloud

If a relative URL is given (`:url` keyword option, or a combination of `:space_id` and `:content_id` options), the fully-qualified URL is built in the standard way from the base URL `https://{host}:{port}/durastore/`.

```
> new_content = Duracloud::Content.new(space_id: "rest-api-testing", content_id: "ark:/99999/fk4zzzz")
 => #<Duracloud::Content url="rest-api-testing/ark:/99999/fk4zzzz">
> new_content.body = "test"
 => "test"
> new_content.content_type = "text/plain"
 => "text/plain"
> new_content.save
 => #<Duracloud::Content url="rest-api-testing/ark:/99999/fk4zzzz">
```

### Retrieve an existing content item from DuraCloud

```ruby
Duracloud::Content.find(**options) # :url, or :space_id and :content_id
```

### Update the properties for an item

TODO

### Delete a content item

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
