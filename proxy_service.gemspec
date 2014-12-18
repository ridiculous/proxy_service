# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'proxy_service/version'

Gem::Specification.new do |spec|
  spec.name          = "proxy_service"
  spec.version       = ProxyService::VERSION
  spec.authors       = ["Ryan Buckley"]
  spec.email         = ["arebuckley@gmail.com"]
  spec.summary       = %q{Manages rotation of proxies using a queue}
  spec.description   = %q{Manages rotation of proxies using a queuing system and STOMP}
  spec.homepage      = "https://github.com/ridiculous/proxy_service"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.1'

  spec.add_runtime_dependency 'queue_worker', '~> 1.0', '>= 1.0.1'
  spec.add_runtime_dependency 'mechanize', '~> 2.7', '>= 2.7.3'
end
