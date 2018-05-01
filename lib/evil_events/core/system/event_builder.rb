# frozen_string_literal: true

class EvilEvents::Core::System
  # @api private
  # @since 0.1.0
  class EventBuilder
    # @return [EvilEvents::Core::Events::Serializers]
    #
    # @api private
    # @since 0.4.0
    attr_reader :serializers_container

    # @api private
    # @since 0.4.0
    def initialize
      @serializers_container = EvilEvents::Core::Events::Serializers.new

      @serializers_container.register_core_serializers!
    end

    # @param event_type [String]
    # @param event_class_definitions [Proc]
    # @return [Class{EvilEvents::Core::Events::AbstractEvent}]
    #
    # @since 0.1.0
    def define_event_class(event_type, &event_class_definitions)
      EvilEvents::Core::Events::EventFactory.create_class(event_type, &event_class_definitions)
    end

    # @param event_type [String]
    # @return [Class{EvilEvents::Core::Events::AbstractEvent}]
    #
    # @since 0.1.0
    def define_abstract_event_class(event_type)
      EvilEvents::Core::Events::EventFactory.create_abstract_class(event_type)
    end

    # @param event [EvilEvents::Core::Events::AbstractEvent]
    # @return [::Hash]
    #
    # @api private
    # @since 0.4.0
    def serialize_to_hash(event)
      serializers_container.resolve(:hash).serialize(event)
    end

    # @param event [EvilEvents::Core::Events::AbstractEvent]
    # @return [::String]
    #
    # @api private
    # @since 0.4.0
    def serialize_to_json(event)
      serializers_container.resolve(:json).serialize(event)
    end

    # @param event [EvilEvents::Core::Events::AbstractEvent]
    # @return [::String]
    #
    # @api private
    # @since 0.4.0
    def serialize_to_xml(event)
      serializers_container.resolve(:xml).serialize(event)
    end

    # @param event [EvilEvents::Core::Events::AbstractEvent]
    # @return [::String]
    #
    # @api private
    # @since 0.4.0
    def serialize_to_msgpack(event)
      serializers_container.resolve(:msgpack).serialize(event)
    end

    # @param serialized_event [String]
    # @return [EvilEvents::Core::Events::AbstractEvent]
    #
    # @since 0.1.0
    def deserialize_from_json(serialized_event)
      serializers_container.resolve(:json).deserialize(serialized_event)
    end

    # @param serialized_event [Hash]
    # @return [EvilEvents::Core::Events::AbstractEvent]
    #
    # @since 0.1.0
    def deserialize_from_hash(serialized_event)
      serializers_container.resolve(:hash).deserialize(serialized_event)
    end

    # @param serialized_event [String]
    # @return [EvilEvents::Core::Events::AbstractEvent]
    #
    # @since 0.4.0
    def deserialize_from_xml(serialized_event)
      serializers_container.resolve(:xml).deserialize(serialized_event)
    end

    # @param serialized_event [String]
    # @return [EvilEvents::Core::Events::AbstractEvent]
    #
    # @since 0.4.0
    def deserialize_from_msgpack(serialized_event)
      serializers_container.resolve(:msgpack).deserialize(serialized_event)
    end
  end
end
