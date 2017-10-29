# frozen_string_literal: true

module EvilEvents::Core::Broadcasting
  # @api private
  # @since 0.1.0
  class Emitter
    # @since 0.1.0
    EmitterError = Class.new(StandardError)
    # @since 0.1.0
    IncorrectEventError = Class.new(EmitterError)

    # @param event [EvilEvents::Core::Events::AbstractEvent]
    # @raise [IncorrectEventError]
    # @return void
    #
    # @since 0.1.0
    def emit(event)
      raise IncorrectEventError unless event.is_a?(EvilEvents::Core::Events::AbstractEvent)
      log_activity(event)
      event.adapter.call(event)
    end

    # @param event_type [String]
    # @param event_attributes [Hash]
    # @return void
    #
    # @since 0.1.0
    def raw_emit(event_type, **event_attributes)
      event_object = EvilEvents::Core::Bootstrap[:event_system].resolve_event_object(
        event_type,
        **event_attributes
      )

      emit(event_object)
    end

    private

    # @param event [EvilEvents::Core::Events::AbstractEvent]
    # @return void
    #
    # @since 0.1.0
    def log_activity(event)
      activity = "EventEmitted(#{event.adapter_name})"
      message  = "ID: #{event.id} :: " \
                 "TYPE: #{event.type} :: " \
                 "PAYLOAD: #{event.payload} :: " \
                 "METADATA: #{event.metadata}"

      EvilEvents::Core::ActivityLogger.log(activity: activity, message: message)
    end
  end
end
