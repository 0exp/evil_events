# frozen_string_literal: true

class EvilEvents::Core::Broadcasting::Emitter
  # @api private
  # @since 0.4.0
  class AdapterProxy
    # @return [Symbol]
    #
    # @api private
    # @since 0.4.0
    attr_reader :identifier

    # @param event [EvilEvents::Core::Events::AbstractEvent]
    # @param explicit_identifier [Symbol,NilClass]
    #
    # @api private
    # @since 0.4.0
    def initialize(event, explicit_identifier: nil)
      @event      = event
      @identifier = explicit_identifier || event.adapter_name
      @adapter    = EvilEvents::Core::Bootstrap[:event_system].resolve_adapter(@identifier)
    end

    # @return [void]
    #
    # @api private
    # @since 0.4.0
    def broadcast!
      adapter.call(event)
    end

    private

    # @return [EvilEvents::Core::Events::AbstractEvent]
    #
    # @api private
    # @since 0.4.0
    attr_reader :event

    # @return [EvilEvents::Core::Broadcasting::Dispatcher::Mixin]
    #
    # @api private
    # @since 0.4.0
    attr_reader :adapter
  end
end
