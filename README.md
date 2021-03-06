# duracloud-ruby-client

Ruby client for communicating with DuraCloud

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'duracloud-client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install duracloud-client

## Usage

### Configure the client

Option 1. Environment variables

    DURACLOUD_HOST
    DURACLOUD_PORT
    DURACLOUD_USER
    DURACLOUD_PASSWORD

Option 2. Manual configuration

*Changed in v0.10.0* Set attributes on `Duracloud` module instead of using `Duracloud::Client.configure {|config| ...}` block.

    Duracloud.host = "foo.duracloud.org"
    Duracloud.user = "bob@example.com"
    Duracloud.password = "s3cret"

#### Logging

By default duracloud-client logs to `STDERR`.  Use the `logger` config setting to change:

    Duracloud.logger = Rails.logger

You can also silence logging:

    Duracloud.silence_logging! # sets logger device to null device

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
D, [2016-04-29T12:12:32.641574 #28275] DEBUG -- : Duracloud::Request PUT https://foo.duracloud.org/durastore/rest-api-testing2 201 Created
 => #<Duracloud::Space space_id="rest-api-testing2", store_id="(default)"> 
```

A `Duracloud::BadRequestError` exception is raised if the space ID is invalid (illegal characters, too long, etc.).

#### Retrieve a space and view its properties

```
>> space = Duracloud::Space.find("rest-api-testing")
D, [2016-04-29T12:15:12.593075 #28275] DEBUG -- : Duracloud::Request HEAD https://foo.duracloud.org/durastore/rest-api-testing 200 OK
 => #<Duracloud::Space space_id="rest-api-testing", store_id="(default)">
 
>> space.count
 => 8

>> space.created
 => #<DateTime: 2016-04-05T17:59:11+00:00 ((2457484j,64751s,0n),+0s,2299161j)> 
```

A `Duracloud::NotFoundError` exception is raised if the space does not exist.

**Note:** When the object count in a space exceeds 1000, Duracloud returns `1000+` as the count. Ruby's integer coercion `to_i`
turns that string into the integer 1000.  Getting an exact count above 1000 requires (on the client side) enumerating the content_ids
(below, fixed in v0.7.2 when count is >= 1000) which can take a long time for a space with a lot of content items
(a maxiumum of 1000 ids can be retrived at one time). If an up-to-the-minute
count is not required, the storage report for the space shows an exact count on a daily basis.

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

#### Sync Validation

*New in version 0.6.0*

Sync validation is the process of comparing the files in a local content directory with content in a DuraCloud space in order to confirm that all local content has been successfully sync.  This functionality is NOT part of the DuraCloud REST API and is provided AS IS (per the license terms).

Assumptions:
- The external program `md5deep` is installed and available on the user's path. See http://md5deep.sourceforge.net/ for `md5deep` documentation and download packages.
- The content IDs in the target DuraCloud space match the relative paths of files in the source content directory -- i.e., no support for "prefixes" (this may change in the future).

Process:
- The space manifest is downloaded from DuraCloud and converted to the expected input format for `md5deep` (two columns: md5 hash and file path, separated by two spaces).
- `md5deep` is run against the content directory in "non-matching" mode (-X) with the converted manifest as the list of "known hashes".
- Non-matching files from the `md5deep` run are re-checked individually by calling `Duracloud::Content.exist?`.
This pass will account for content sync after `md5deep` started as well as files that have been chunked in DuraCloud.
Results of this re-check are printed to STDOUT (or, if using the `:work_dir` option, below, to a file).

```ruby
Duracloud::SyncValidation.call(space_id: 'foo', content_dir: '/var/foo/bar')
```

*Added in version 0.9.0* - `:work_dir` option to specify existing directory in which to write validation files. The default behavior is to
create a temporary directory which is deleted on completion of the process. If `:work_dir` is specified, no cleanup is performed.

Files created in work directory:

    {SPACE_ID}-manifest.tsv   DuraCloud manifest as downloaded
    {SPACE_ID}-md5.txt        Munged manifest for md5deep
    {SPACE_ID}-audit.txt      Output of md5deep, empty if all files match
    {SPACE_ID}-recheck.txt    Output of audit recheck, if necessary

*Added in version 0.9.0* - `Duracloud::FastSyncValidation`. This variant of sync validation does not compute local hashes but instead compares the local file list (generated with `find`) to the list of content IDs in the space manifest. Local misses are rechecked as in `SyncValidation` (but without MD5 comparison).

### Content

#### Create a new content item and store it in DuraCloud

```
>> new_content = Duracloud::Content.new(space_id: "rest-api-testing", content_id: "ark:/99999/fk4zzzz")
 => #<Duracloud::Content space_id="rest-api-testing", content_id="ark:/99999/fk4zzzz", store_id=(default)>
 
>> new_content.body = "test"
 => "test"

>> new_content.content_type = "text/plain"
 => "text/plain"
 
>> new_content.save
 => #<Duracloud::Content space_id="rest-api-testing", content_id="ark:/99999/fk4zzzz", store_id=(default)>
```

When storing content a `Duracloud::NotFoundError` is raised if the space does not exist.
A `Duracloud::BadRequestError` is raised if the content ID is invalid.
A `Duracloud::ConflictError` is raised if the provided MD5 digest does not match the stored digest.

**Note:** duracloud-client does not currently provide for chunking of large files as, for example, the DuraCloud Sync Tool does.

#### Retrieve an existing content item from DuraCloud

```
>> Duracloud::Content.find(space_id: "spaceID", content_id: "contentID")
 => #<Duracloud::Content space_id="spaceID", content_id="contentID", store_id=(default)>
```

If the space or content ID does not exist, a `Duracloud::NotFoundError` is raised.
If an MD5 digest is provided (:md5 attribute), a `Duracloud::MessageDigestError` is
raised if the content ID exists and the stored digest does not match.

*Added in v0.4.0*

If a content item is not found at the content ID, `Duracloud::Content.find` will look for a "content manifest"
by appending ".dura-manifest" to the content ID. If the manifest is found, the content item is marked as
"chunked". **Caution: Working with chunked files should be considered EXPERIMENTAL and unsupported.**

#### Update the properties for a content item

```
>> space = Duracloud::Space.find("rest-api-testing")
 => #<Duracloud::Space space_id="rest-api-testing", store_id="(default)">

>> content = space.find_content("foo3")
D, [2016-04-29T18:31:16.975749 #32379] DEBUG -- : Duracloud::Request HEAD https://foo.duracloud.org/durastore/rest-api-testing/foo3 200 OK
 => #<Duracloud::Content space_id="rest-api-testing", content_id="foo3", store_id=(default)>

>> content.properties
 => #<Duracloud::ContentProperties x-dura-meta-owner="ellen@example.com">

>> content.properties["x-dura-meta-creator"] = "bob@example.com"
>> content.save
D, [2016-04-29T18:31:52.770195 #32379] DEBUG -- : Duracloud::Request POST https://foo.duracloud.org/durastore/rest-api-testing/foo3 200 OK
I, [2016-04-29T18:31:52.770293 #32379]  INFO -- : Content foo3 updated successfully
 => true

>> content.properties["x-dura-meta-creator"]
D, [2016-04-29T18:32:06.465928 #32379] DEBUG -- : Duracloud::Request HEAD https://foo.duracloud.org/durastore/rest-api-testing/foo3 200 OK
 => "bob@example.com"
```     

#### Copy a content item

*Added in v0.3.0; Changed in v0.4.0.*

Accepts same keywords as `.find` and `.new` -- `:space_id`, `:content_id`, `:store_id` -- plus `:force`.

The `:force` argument is a boolean (default `false`) indicating whether to replace existing content (if found) at the target location. If `:force` is false and content exists at the target location, the operation raises a `Duracloud::Content::CopyError` exception.

Also, `:space_id` and `:content_id` arguments are not required, but default to the values of the current content object's attributes. An exception is raised if the source and destination locations are the same (regardless of the value of `:force`).

```
>> content = Duracloud::Content.find(space_id: 'rest-api-testing', content_id: 'contentItem.txt')
D, [2017-01-27T17:16:45.846459 #93283] DEBUG -- : Duracloud::Request HEAD https://duke.duracloud.org/durastore/rest-api-testing/contentItem.txt 200 OK
 => #<Duracloud::Content space_id="rest-api-testing", content_id="contentItem.txt", store_id=(default)> 

>> content.copy(space_id: 'rest-api-testing2')
D, [2017-01-27T17:17:59.848741 #93283] DEBUG -- : Duracloud::Request PUT https://duke.duracloud.org/durastore/rest-api-testing2/contentItem.txt 201 Created
 => #<Duracloud::Content space_id="rest-api-testing2", content_id="contentItem.txt", store_id=(default)> 
```

#### Move a content item

*Added in v0.3.0; Changed in v0.4.0.*

See also *Copy a content item*, above.

```
This is a convenience operation -- copy and delete -- not directly supported by the DuraCloud REST API.

>> content = Duracloud::Content.find(space_id: 'rest-api-testing', content_id: 'contentItem.txt')
D, [2017-01-27T17:19:41.926994 #93286] DEBUG -- : Duracloud::Request HEAD https://duke.duracloud.org/durastore/rest-api-testing/contentItem.txt 200 OK
 => #<Duracloud::Content space_id="rest-api-testing", content_id="contentItem.txt", store_id=(default)> 

>> content.move(space_id: 'rest-api-testing2')
D, [2017-01-27T17:20:07.542468 #93286] DEBUG -- : Duracloud::Request PUT https://duke.duracloud.org/durastore/rest-api-testing2/contentItem.txt 201 Created
D, [2017-01-27T17:20:08.442504 #93286] DEBUG -- : Duracloud::Request DELETE https://duke.duracloud.org/durastore/rest-api-testing/contentItem.txt 200 OK
 => #<Duracloud::Content space_id="rest-api-testing2", content_id="contentItem.txt", store_id=(default)> 

>> content.deleted?
 => true 
```

#### Delete a content item

```
>> space = Duracloud::Space.find("rest-api-testing")
 => #<Duracloud::Space space_id="rest-api-testing", store_id="(default)">

>> content = space.find_content("foo2")
 => #<Duracloud::Content space_id="rest-api-testing", content_id="foo2", store_id=(default)>

>> content.delete
D, [2016-04-29T18:28:31.459962 #32379] DEBUG -- : Duracloud::Request DELETE https://foo.duracloud.org/durastore/rest-api-testing/foo2 200 OK
I, [2016-04-29T18:28:31.460069 #32379]  INFO -- : Content foo2 deleted successfully
 => #<Duracloud::Content space_id="rest-api-testing", content_id="foo2", store_id=(default)>

>> Duracloud::Content.exist?(space_id: "rest-api-testing", content_id: "foo2")
D, [2016-04-29T18:29:03.935451 #32379] DEBUG -- : Duracloud::Request HEAD https://foo.duracloud.org/durastore/rest-api-testing/foo2 404 Not Found
 => false
```

*Added in v0.10.0.pre* `Duracloud::Content.delete` class method.

### Reports

The audit logs, bit integrity reports and manifests are accessible in their original TSV format and in normalized CSV tables.

#### Audit Log

```
>> space = Duracloud::Space.find("rest-api-testing")
>> audit_log = space.audit_log
 => #<Duracloud::AuditLog:0x007fd44c077f38 @space_id="rest-api-testing", @store_id=nil, @response=nil>

>> audit_log.csv
D, [2016-05-19T13:36:49.107520 #28754] DEBUG -- : Duracloud::Request GET https://duke.duracloud.org/durastore/audit/rest-api-testing 200 OK
 => #<CSV::Table mode:col_or_row row_count:168>
```

#### Manifest

```
>> space = Duracloud::Space.find("rest-api-testing")
>> manifest = space.manifest
 => #<Duracloud::Manifest:0x007fd44d3c7048 @space_id="rest-api-testing", @store_id=nil, @tsv_response=nil, @bagit_response=nil>

>> manifest.csv
D, [2016-05-19T13:37:39.831013 #28754] DEBUG -- : Duracloud::Request GET https://duke.duracloud.org/durastore/manifest/rest-api-testing 200 OK
 => #<CSV::Table mode:col_or_row row_count:10>

>> manifest.csv.headers
 => ["space_id", "content_id", "md5"]
```

*Added in v0.5.0* Support for asynchronous generation of manifest (Generate Manifest API)

```
>> manifest = Duracloud::Manifest.new('ddr-validation')
 => #<Duracloud::Manifest:0x007f8fd82fe328 @space_id="ddr-validation", @store_id=nil>
>> manifest.generate
 D, [2017-06-06T20:49:50.191301 #92029] DEBUG -- : Duracloud::Request POST https://duke.duracloud.org/durastore/manifest/ddr-validation 202 Accepted
 I, [2017-06-06T20:49:50.191414 #92029]  INFO -- : We are processing your manifest generation request. To retrieve your file, please poll the URI in the Location header of this response: (https://duke.duracloud.org/durastore/x-duracloud-admin/generated-manifests/manifest-ddr-validation_amazon_s3_2017-06-07-00-49-50.txt.gz).
 => "https://duke.duracloud.org/durastore/x-duracloud-admin/generated-manifests/manifest-ddr-validation_amazon_s3_2017-06-07-00-49-50.txt.gz"
```  

#### Bit Integrity Report

```
>> space = Duracloud::Space.find("rest-api-testing")
>> bit_integrity_report = space.bit_integrity_report
 => #<Duracloud::BitIntegrityReport:0x007f88e39a2950 @space_id="rest-api-testing", @store_id=nil, @report=nil, @properties=nil>

>> bit_integrity_report.csv
D, [2016-05-19T15:39:33.538448 #29974] DEBUG -- : Duracloud::Request GET https://duke.duracloud.org/durastore/bit-integrity/rest-api-testing 200 OK
 => #<CSV::Table mode:col_or_row row_count:8> 
```

### Command Line Interface

*New in version 0.6.0*

The `bin/` directory of the gem now includes an executable `duracloud`.  Use `-h/--help` to display usage.
If the gem was installed with `bundler` you may need to run `bundle exec bin/duracloud`.

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
