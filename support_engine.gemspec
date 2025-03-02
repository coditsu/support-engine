# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'support_engine/version'

Gem::Specification.new do |spec|
  spec.name          = 'support_engine'
  spec.version       = SupportEngine::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.authors       = ['Maciej Mensfeld']
  spec.email         = %w[contact@coditsu.io]
  spec.homepage      = 'https://coditsu.io'
  spec.summary       = 'Shared libraries for Coditsu Quality Assurance tool'
  spec.description   = 'Shared libraries for Coditsu Quality Assurance tool'
  spec.license       = 'LGPL-3.0'

  spec.add_dependency 'activesupport', '< 8'
  spec.add_dependency 'logger'
  spec.add_dependency 'zeitwerk'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec)/}) }
  spec.require_paths = %w[lib]
end
