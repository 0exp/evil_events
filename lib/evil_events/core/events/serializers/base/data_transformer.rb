# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers::Base
  # @api private
  # @since 0.4.0
  class DataTransformer
    # @param engine [Base::Engine::Abstract]
    #
    # @api private
    # @since 0.4.0
    def initialize(engine)
      @engine = engine
    end

    # @param event [EvilEvents::Core::Events::AbstractEvent]
    # @return [Object]
    #
    # @api private
    # @since 0.4.0
    def call(event); end

    private

    # @return [Base::Engine::Abstract]
    #
    # @api private
    # @since 0.4.0
    attr_reader :engine

    # @param event [EvilEvents::Core::Events::AbstractEvent]
    # @return [EventSerializationState]
    #
    # @api private
    # @since 0.4.0
    def build_serialization_state(event)
      EventSerializationState.build_from_event(event)
    end

    # @param serialization_state [EventSerializationState]
    # @return [EvilEvents::Core::Events::AbstractEvent]
    #
    # @api private
    # @since 0.4.0
    def restore_event_instance(serialization_state)
      event_class = EvilEvents::Core::Bootstrap[:event_system].resolve_event_class(
        serialization_state.type
      )

      EvilEvents::Core::Events::EventFactory.restore_instance(
        event_class,
        id: serialization_state.id,
        payload: serialization_state.payload,
        metadata: serialization_state.metadata
      )
    end
  end
end
