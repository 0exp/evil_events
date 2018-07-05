# frozen_string_literal: true

require 'simplecov'
require 'simplecov-json'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter,
  Coveralls::SimpleCov::Formatter
])

SimpleCov.start { add_filter 'spec' }

require 'pry'
require 'bundler/setup'
require 'dry/container/stub'
require 'evil_events'

require_relative 'support/spec_support'
require_relative 'support/shared_examples'
require_relative 'support/shared_contexts'
require_relative 'support/application_state_metascopes'

RSpec.configure do |config|
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.order = :random
  Kernel.srand config.seed

  config.include SpecSupport::EventFactories
  config.include SpecSupport::NotifierFactories
  config.include SpecSupport::EventManagerFactories
  config.include SpecSupport::DispatchingAdapterFactories
  config.include SpecSupport::FakeDataGenerator
  config.extend  SpecSupport::FakeDataGenerator
end
