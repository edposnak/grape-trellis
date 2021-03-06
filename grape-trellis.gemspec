# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'grape_trellis/version'

Gem::Specification.new do |spec|
  spec.name          = "grape-trellis"
  spec.version       = Grape::Trellis::VERSION
  spec.authors       = ["Ed Posnak"]
  spec.email         = ["ed.posnak@gmail.com"]
  spec.summary       = %q{scaffold code generator for Grape}
  spec.description   = %q{generates apis, models, and presenters for grape API projects}

  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'abstract_method'
  spec.add_dependency 'activesupport'

  # Need sequel and pg for database reflection
  spec.add_dependency 'pg'
  spec.add_dependency 'sequel'
  spec.add_dependency 'sequel_pg'  # require: 'sequel'

  spec.add_dependency 'dart'

  spec.add_dependency 'thor'

  #############################################################################
  # Development dependencies

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'mocha'

end
