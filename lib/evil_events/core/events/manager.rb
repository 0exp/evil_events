# frozen_string_literal: true

module EvilEvents::Core::Events
  # @api private
  # @since 0.1.0
  class Manager
    # @since 0.1.0
    ManagerError = Class.new(EvilEvents::Core::Error)
    # @since 0.1.0
    InconsistentEventClassError = Class.new(ManagerError)
    # @since 0.1.0
    InvalidDelegatorTypeError = Class.new(ManagerError)

    # @return [EvilEvents::Core::Events::AbstractEvent]
    #
    # @since 0.1.0
    attr_reader :event_class

    # @return [Concurrent::Array<EvilEvents::Core::Events::Subscriber>]
    #
    # @since 0.1.0
    attr_reader :subscribers

    # @param event_class [Class{EvilEvents::Core::Events::AbstractEvent}]
    #
    # @since 0.1.0
    def initialize(event_class)
      @event_class = event_class
      @subscribers = SubscriberList.new
    end

    # @param raw_subscriber [Object]
    # @param delegator [Symbol, String, NilClass]
    # @raise [InvalidDelegatorTypeError]
    # @return void
    #
    # @since 0.1.0
    def observe(raw_subscriber, delegator = nil)
      case delegator
      when NilClass, Symbol, String
        subscribers.push(create_event_subscriber(raw_subscriber, delegator))
      else
        raise InvalidDelegatorTypeError
      end
    end

    # @param event [EvilEvents::Core::Events::AbstractEvent]
    # @raise [Notifier::InconsistentEventClassError]
    # @raise [Notifier::FailedSubscribersError]
    #
    # @return void
    #
    # @since 0.1.0
    def notify(event)
      Notifier.run(self, event)
    end

    # @return [String, Symbol]
    #
    # @since 0.1.0
    def event_type
      event_class.type
    end

    private

    # @param raw_subscriber [Object]
    # @param delegator [Symbol, String, NilClass]
    # @return [EvilEvents::Core::Events::Subscriber]
    #
    # @since 0.1.0
    def create_event_subscriber(raw_subscriber, delegator)
      delegation = -> { delegator || event_class.default_delegator }
      resolver   = EvilEvents::Shared::DelegatorResolver.new(delegation)
      EvilEvents::Core::Events::Subscriber.new(raw_subscriber, resolver)
    end
  end
end
