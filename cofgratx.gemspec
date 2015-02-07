# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cofgratx/version'

Gem::Specification.new do |spec|
  spec.name          = "cofgratx"
  spec.version       = Cofgratx::VERSION
  spec.authors       = ["callahat"]
  spec.email         = ["tim.callahan25@yahoo.com"]
  spec.summary       = "A context free grammar validator and translator"
  spec.description   = "The CFG class can be used to create a specification for a context free grammar and define translations for it"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
