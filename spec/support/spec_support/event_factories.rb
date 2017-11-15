# frozen_string_literal: true

module SpecSupport::EventFactories
  module_function

  def build_event_class_stub
    Class.new do
      def initialize(id: nil, payload: {}, metadata: {}); end

      yield(self) if block_given?
    end
  end

  def build_abstract_event_class(type_alias)
    EvilEvents::Core::Events::EventFactory.create_abstract_class(type_alias)
  end

  def build_event_class(type_alias, &definitions)
    EvilEvents::Core::Events::EventFactory.create_class(type_alias, &definitions)
  end
end
