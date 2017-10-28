# frozen_string_literal: true

class EvilEvents::Core::System
  # @api private
  # @since 0.1.0
  module EventBuilder
    class << self
      # @param event_type [String]
      # @param event_class_definitions [Proc]
      # @return [Class{EvilEvents::Core::Events::AbstractEvent}]
      #
      # @since 0.1.0
      def define_event_class(event_type, &event_class_definitions)
        EvilEvents::Core::Events::EventClassFactory.create(event_type, &event_class_definitions)
      end

      # @param event_type [String]
      # @return [Class{EvilEvents::Core::Events::AbstractEvent}]
      #
      # @since 0.1.0
      def define_abstract_event_class(event_type)
        EvilEvents::Core::Events::EventClassFactory.create_abstract(event_type)
      end

      # @param serialized_event [String]
      # @return [EvilEvents::Core::Events::AbstractEvent]
      #
      # @since 0.1.0
      def deserialize_from_json(serialized_event)
        EvilEvents::Core::Events::Serializers.resolve(:json).deserialize(serialized_event)
      end

      # @param serialized_event [Hash]
      # @return [EvilEvents::Core::Events::AbstractEvent]
      #
      # @since 0.1.0
      def deserialize_from_hash(serialized_event)
        EvilEvents::Core::Events::Serializers.resolve(:hash).deserialize(serialized_event)
      end
    end
  end
end
