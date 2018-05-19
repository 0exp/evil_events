# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers::XML::Engines
  # @api private
  # @since 0.5.0
  class Ox < EvilEvents::Core::Events::Serializers::Base::AbstractEngine
    # @param serialization_state [Base::EventSerializationState]
    # @return [String]
    #
    # @since 0.5.0
    # @api private
    def dump(serialization_state)
      ::Ox.dump(serialization_state)
    end

    # @param xml [String]
    # @raise [EvilEvents::SerializationEngineError]
    # @return [EventSerializationState]
    #
    # @since 0.5.0
    # @api private
    def load(xml)
      ::Ox.parse_obj(xml)
    rescue ::Ox::Error, NoMethodError, TypeError, ArgumentError
      raise EvilEvents::SerializationEngineError
    end
  end

  # @since 0.5.0
  register(:ox, Ox)
end
