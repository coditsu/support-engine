# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'support_engine/version'

Gem::Specification.new do |spec|
  spec.name          = 'support_engine'
  spec.version       = ::SupportEngine::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.authors       = ['Maciej Mensfeld']
  spec.email         = %w[maciej@mensfeld.pl]
  spec.homepage      = 'https://coditsu.com'
  spec.summary       = 'Shared libraries for Coditsu Quality Assurance tool'
  spec.description   = 'Shared libraries for Coditsu Quality Assurance tool'
  spec.license       = 'Trade secret'

  spec.add_dependency 'activesupport'
  spec.add_dependency 'require_all'
  spec.add_development_dependency 'bundler'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec)/}) }
  spec.require_paths = %w[lib]
end
