# frozen_string_literal: true

class EvilEvents::Core::Broadcasting::Emitter
  # @api private
  # @since 0.4.0
  class AdapterProxy
    # @param event [EvilEvents::Core::Events::AbstractEvent]
    # @param explicit_adapter_identifier [Symbol,NilClass]
    #
    # @api private
    # @since 0.4.0
    def initialize(event, explicit_adapter_identifier = nil)
      @event = event
      @explicit_adapter_identifier = explicit_adapter_identifier
    end

    # @return [Symbol]
    #
    # @api private
    # @since 0.4.0
    def identifier
      explicit_adapter_identifier ? explicit_adapter_identifier : event.adapter_name
    end

    # @return [void]
    #
    # @api private
    # @since 0.4.0
    def broadcast!
      resolve_adapter.call(event)
    end

    private

    # @return [EvilEvents::Core::Events::AbstractEvent]
    #
    # @api private
    # @since 0.4.0
    attr_reader :event

    # @return [NilClass,Symbol]
    #
    # @api private
    # @since 0.4.0
    attr_reader :explicit_adapter_identifier

    # @return [EvilEvents::Core::Broadcasting::Dispatcher]
    #
    # @api private
    # @since 0.4.0
    def resolve_adapter
      EvilEvents::Core::Bootstrap[:event_system].resolve_adapter(identifier)
    end
  end
end
