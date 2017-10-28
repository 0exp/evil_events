# frozen_string_literal: true

module SpecSupport::EventManagerFactories
  module_function

  def build_event_manager(event_class)
    EvilEvents::Core::Events::ManagerFactory.create(event_class)
  end
end
