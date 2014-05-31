# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aviator/version'
require 'rbconfig'

Gem::Specification.new do |spec|
  spec.name          = "aviator"
  spec.version       = Aviator::VERSION
  spec.authors       = ["Mark Maglana"]
  spec.email         = ["mmaglana@gmail.com"]
  spec.description   = %q{ A lightweight Ruby library for the OpenStack API }
  spec.summary       = %q{ A lightweight Ruby library for the OpenStack API }
  spec.homepage      = "http://aviator.github.io/www/"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'faraday', '0.8.8'
  spec.add_dependency 'activesupport', '>= 3.2.8'
  spec.add_dependency 'thor', '~> 0.18.1'
  spec.add_dependency 'terminal-table', '>= 1.4.5'

  spec.add_development_dependency "bundler", ">= 1.0"
  spec.add_development_dependency 'rb-fsevent', '~> 0.9.0'
  spec.add_development_dependency 'guard', '~> 1.8.0'
  spec.add_development_dependency 'guard-rake', '~> 0.0.0'
  spec.add_development_dependency 'guard-minitest', '~> 0.5.0'

  if /darwin|mac os/ === RbConfig::CONFIG['host_os']
    spec.add_development_dependency 'terminal-notifier-guard', '~> 1.5.3'
  else
    spec.add_development_dependency 'ruby_gntp', '~> 0.3.0'
  end

  spec.add_development_dependency 'pry', '~> 0.9.0'
  spec.add_development_dependency 'yard', '~> 0.8.0'
  spec.add_development_dependency 'redcarpet', '~> 2.3.0'
end
