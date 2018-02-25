# frozen_string_literal: true

module SpecSupport
  require_relative 'spec_support/fake_data_generator'
  require_relative 'spec_support/null_logger'
  require_relative 'spec_support/dumb_event_serializer'
  require_relative 'spec_support/event_factories'
  require_relative 'spec_support/event_manager_factories'
  require_relative 'spec_support/dispatching_adapter_factories'
  require_relative 'spec_support/notifier_factories'
end
