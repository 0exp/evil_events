# frozen_string_literal: true

module SpecSupport::EventFactories
  module_function

  EventFactoriesError  = Class.new(StandardError)
  EventSubscriberError = Class.new(EventFactoriesError)

  def build_event_class_mock
    Class.new do
      class << self
        def payload(*); end

        def metadata(*); end
      end

      attr_reader :id
      attr_reader :payload
      attr_reader :metadata

      def initialize(id: nil, payload: {}, metadata: {})
        @id       = id
        @payload  = payload
        @metadata = metadata
      end

      yield(self) if block_given?
    end
  end

  def build_event_class_stub
    Class.new do
      attr_reader :id
      attr_reader :payload
      attr_reader :metadata

      def initialize(id: nil, payload: {}, metadata: {})
        @id       = id
        @payload  = payload
        @metadata = metadata
      end

      yield(self) if block_given?
    end
  end

  def build_abstract_event_class(type_alias = gen_str(only_letters: true))
    EvilEvents::Core::Events::EventFactory.create_abstract_class(type_alias)
  end

  def build_event_class(type_alias = gen_str(only_letters: true), &definitions)
    EvilEvents::Core::Events::EventFactory.create_class(type_alias, &definitions)
  end

  def build_event_subscriber(failing: false)
    source_subscriber = lambda do |event|
      raise EventSubscriberError if failing
      yield if block_given?
    end

    delegator = -> { :call }
    delegator_resolver = EvilEvents::Shared::DelegatorResolver.new(delegator)
    EvilEvents::Core::Events::Subscriber.new(source_subscriber, delegator_resolver)
  end

  def build_event_manager(event_class)
    EvilEvents::Core::Events::Manager.new(event_class)
  end
end
