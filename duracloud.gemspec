# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'duracloud/version'

Gem::Specification.new do |spec|
  spec.name          = "duracloud-client"
  spec.version       = Duracloud::VERSION
  spec.authors       = ["David Chandek-Stark"]
  spec.email         = ["dchandekstark@gmail.com"]
  spec.summary       = "Ruby client for communicating with DuraCloud"
  spec.description   = "Ruby client for communicating with DuraCloud"
  spec.homepage      = "https://github.com/duracloud/duracloud-ruby-client"
  spec.license       = "APACHE2"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "hashie", "~> 3.4"
  spec.add_dependency "httpclient", "~> 2.7"
  spec.add_dependency "activemodel", "~> 4.2"

  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "rspec-its", "~> 1.2"
  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 11.1"
end
