# frozen_string_literal: true

module EvilEvents
  # @since 0.3.0
  Error = Class.new(StandardError)
  # @since 0.3.0
  ArgumentError = Class.new(ArgumentError)

  # NOTE: see EvilEvents::Core::Broadcasting::Emitter
  # @since 0.3.0
  EmitterError = Class.new(Error)
  # since 0.3.0
  IncorrectEventForEmitError = Class.new(EmitterError)

  # NOTE: see EvilEvents::Core::Events::EventExtensions::TypeAliasing
  # @since 0.3.0
  TypeAliasingError = Class.new(Error)
  # @since 0.3.0
  IncopatibleEventTypeError = Class.new(TypeAliasingError)
  # @since 0.3.0
  EventTypeNotDefinedError = Class.new(TypeAliasingError)
  # @since 0.3.0
  EventTypeAlreadyDefinedError = Class.new(TypeAliasingError)

  # NOTE: see EvilEvents::Core::Events::Notifier::Builder
  # @since 0.3.0
  NotifierBuilderError = Class.new(Error)
  # @since 0.3.0
  UnknownNotifierTypeError = Class.new(NotifierBuilderError)

  # NOTE: see EvilEvents::Core::Events::Manager
  # @since 0.3.0
  ManagerError = Class.new(Error)
  # @since 0.3.0
  InconsistentEventClassError = Class.new(ManagerError)
  # @since 0.3.0
  InvalidDelegatorTypeError = Class.new(ManagerError)

  # NOTE: see EvilEvents::Core::Events::ManagerFactory
  # @since 0.3.0
  ManagerFactoryError = Class.new(Error)
  # @since 0.3.0
  IncorrectEventClassError = Class.new(ManagerFactoryError)

  # NOTE: see EvilEvents::Core::Events::ManagerRegistry
  # @since 0.3.0
  ManagerRegistryError = Class.new(Error)
  # @since 0.3.0
  IncorrectManagerObjectError = Class.new(ManagerRegistryError)
  # @since 0.3.0
  NonManagedEventClassError = Class.new(ManagerRegistryError)
  # @since 0.3.0
  AlreadyManagedEventClassError = Class.new(ManagerRegistryError)

  # NOTE: EvilEvents::Core::Events::Serializers
  # @since 0.3.0
  SerializersError = Class.new(Error)
  # @since 0.3.0
  SerializationError = Class.new(SerializersError)
  # @since 0.3.0
  DeserializationError = Class.new(SerializersError)

  # NOTE: see EvilEvents::Core::Events::Notifier
  # @since 0.3.0
  NotifierError = Class.new(Error)
  # @since 0.3.0
  class FailedNotifiedSubscribersError < NotifierError
    # @since 0.3.0
    extend Forwardable

    # @since 0.3.0
    def_delegators :errors_stack, :<<, :empty?

    # @return [Concurrent::Array]
    #
    # @api public
    # @since 0.3.0
    attr_reader :errors_stack

    # @param message [NilClass, String]
    #
    # @since 0.3.0
    def initialize(message = nil)
      @errors_stack = Concurrent::Array.new
      super
    end
  end

  # NOTE: see EvilEvents::Core::Events::Notifier::Worker::Executor
  # @since 0.3.0
  WorkerError = Class.new(NotifierError)
  # @since 0.3.0
  IncorrectFallbackPolicyError = Class.new(WorkerError)
  # @since 0.3.0
  WorkerDisabledOrBusyError = Class.new(WorkerError)
end
