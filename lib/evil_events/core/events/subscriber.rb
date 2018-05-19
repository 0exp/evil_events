# frozen_string_literal: true

module EvilEvents::Core::Events
  # @api private
  # @since 0.1.0
  class Subscriber
    # @return [EvilEvents::Shared::DelegatorResolver]
    #
    # @since 0.1.0
    attr_reader :delegator_resolver

    # @param subscriber [Object]
    # @param delegator_resolver [EvilEvents::Shared::DelegatorResolver]
    #
    # @since 0.1.0
    def initialize(subscriber, delegator_resolver = default_resolver)
      @subscriber = subscriber
      @delegator_resolver = delegator_resolver
    end

    # @param event [EvilEvents::Core::Events::AbstractEvent]
    # @return void
    #
    # @since 0.1.0
    def notify(event)
      source_object.public_send(delegator, event)
    end

    # @return [Object]
    #
    # @since 0.1.0
    def source_object
      @subscriber
    end

    # @return [String, Symbol]
    #
    # @since 0.1.0
    def delegator
      @delegator ||= delegator_resolver.delegator
    end

    private

    # @return [EvilEvents::Shared::DelegatorResolver]
    #
    # @since 0.1.0
    def default_resolver
      delegation = lambda do
        EvilEvents::Core::Bootstrap[:config].settings.subscriber.default_delegator
      end

      EvilEvents::Shared::DelegatorResolver.new(delegation)
    end
  end
end
