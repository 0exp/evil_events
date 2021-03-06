# frozen_string_literal: true

module EvilEvents::Core::Broadcasting
  # @api private
  # @since 0.1.0
  class Emitter
    # @param event [EvilEvents::Core::Events::AbstractEvent]
    # @option adapter [Symbol,NilClass]
    # @raise [EvilEvents::IncorrectEventForEmitError]
    # @return [void]
    #
    # @since 0.1.0
    def emit(event, adapter: nil)
      unless event.is_a?(EvilEvents::Core::Events::AbstractEvent)
        raise EvilEvents::IncorrectEventForEmitError
      end

      adapter_proxy = AdapterProxy.new(event, explicit_identifier: adapter)

      log_activity(event, adapter_proxy)
      adapter_proxy.broadcast!
    end

    # @param event_type [String]
    # @option id [NilClass,String]
    # @option payload [Hash]
    # @option metadata [Hash]
    # @option adapter [Symbol,NilClass]
    # @return [void]
    #
    # @since 0.1.0
    def raw_emit(event_type, id: nil, payload: {}, metadata: {}, adapter: nil)
      event_object = EvilEvents::Core::Bootstrap[:event_system].resolve_event_object(
        event_type, id: id, payload: payload, metadata: metadata
      )

      emit(event_object, adapter: adapter)
    end

    private

    # @param event [EvilEvents::Core::Events::AbstractEvent]
    # @param adapter_proxy [EvilEvents::Core::Broadcasting::Emitter::AdapterProxy]
    # @return [void]
    #
    # @since 0.1.0
    def log_activity(event, adapter_proxy)
      activity = "EventEmitted(#{adapter_proxy.identifier})"
      message  = "ID: #{event.id} :: " \
                 "TYPE: #{event.type} :: " \
                 "PAYLOAD: #{event.payload} :: " \
                 "METADATA: #{event.metadata}"

      EvilEvents::Core::ActivityLogger.log(activity: activity, message: message)
    end
  end
end
