# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aviator/version'

Gem::Specification.new do |spec|
  spec.name          = "aviator"
  spec.version       = Aviator::VERSION
  spec.authors       = ["Mark Maglana"]
  spec.email         = ["mmaglana@gmail.com"]
  spec.description   = %q{ Lightweight Ruby bindings for the OpenStack API }
  spec.summary       = %q{ Lightweight Ruby bindings for the OpenStack API }
  spec.homepage      = "https://github.com/relaxdiego/aviator"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'faraday', '~> 0.8.0'
  spec.add_dependency 'activesupport', '~> 4.0.0'
  spec.add_dependency 'thor', '~> 0.18.1'
  
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rb-fsevent', '~> 0.9.0'
  spec.add_development_dependency 'guard', '~> 1.8.0'
  spec.add_development_dependency 'guard-rake', '~> 0.0.0'
  spec.add_development_dependency 'guard-minitest', '~> 0.5.0'
  spec.add_development_dependency 'ruby_gntp', '~> 0.3.0'
  spec.add_development_dependency 'debugger', '~> 1.6.0'
  spec.add_development_dependency 'pry', '~> 0.9.0'
  spec.add_development_dependency 'yard', '~> 0.8.0'
  spec.add_development_dependency 'redcarpet', '~> 2.3.0'
end
