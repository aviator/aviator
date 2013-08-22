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

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
