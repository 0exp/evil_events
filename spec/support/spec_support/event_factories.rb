# frozen_string_literal: true

module SpecSupport::EventFactories
  module_function

  def build_event_class_signature
    Class.new do
      def initialize(payload: {}, metadata: {}); end

      yield(self) if block_given?
    end
  end

  def build_abstract_event_class(type_alias)
    EvilEvents::Core::Events::EventClassFactory.create_abstract(type_alias)
  end

  def build_event_class(type_alias, &definitions)
    EvilEvents::Core::Events::EventClassFactory.create(type_alias, &definitions)
  end
end
