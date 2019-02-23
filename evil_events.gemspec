# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'evil_events/version'

Gem::Specification.new do |spec|
  spec.required_ruby_version = '>= 2.3.8'

  spec.name        = 'evil_events'
  spec.version     = EvilEvents::VERSION
  spec.authors     = 'Rustam Ibragimov'
  spec.email       = 'iamdaiver@icloud.com'
  spec.homepage    = 'https://github.com/0exp/evil_events'
  spec.license     = 'MIT'
  spec.summary     = 'Event subsystem for ruby applications'
  spec.description = 'Ultra simple, but very flexible and fully customizable event subsystem ' \
                     'for ruby applications with a wide set of customization interfaces ' \
                     'and smart event definition DSL.'

  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(spec|features)/})
  end

  spec.add_dependency 'dry-monads',      '~> 1.2.0'
  spec.add_dependency 'dry-types',       '~> 0.14.0'
  spec.add_dependency 'dry-struct',      '~> 0.6.0'
  spec.add_dependency 'dry-container',   '~> 0.7.0'
  spec.add_dependency 'concurrent-ruby', '~> 1.0'
  spec.add_dependency 'symbiont-ruby',   '~> 0.4.0'
  spec.add_dependency 'qonfig',          '~> 0.9.0'

  spec.add_development_dependency 'coveralls',        '~> 0.8.22'
  spec.add_development_dependency 'simplecov',        '~> 0.16.1'
  spec.add_development_dependency 'rspec',            '~> 3.8.0'
  spec.add_development_dependency 'armitage-rubocop', '~> 0.21.0'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'yard'
end
