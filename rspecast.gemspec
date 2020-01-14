# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspecast/version'

Gem::Specification.new do |spec|
  spec.name          = 'rspecast'
  spec.version       = Rspecast::VERSION
  spec.authors       = ['Igor Gonchar']
  spec.email         = ['igor.gonchar@gmail.com']

  spec.summary       = 'Build your rspec AST'
  spec.homepage      = 'https://github.com/gigorok/rspecast'
  spec.license       = 'MIT'

  spec.files = Dir['{lib,bin}/**/**']
  spec.executables   = ['rspecast']
  spec.require_paths = ['lib']

  spec.add_dependency 'parser'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
