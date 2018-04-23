# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers::XML::Engines
  # @api private
  # @since 0.4.0
  class Ox < EvilEvents::Core::Events::Serializers::Base::AbstractEngine
    # @param serialization_state [Base::EventSerializationState]
    # @return [String]
    #
    # @since 0.4.0
    # @api private
    def dump(serialization_state)
      ::Ox.dump(serialization_state)
    end

    # @param xml [String]
    # @raise [EvilEvents::XMLDeserializationError]
    # @return [EventSerializationState]
    #
    # @since 0.4.0
    # @api private
    def load(xml)
      ::Ox.parse_obj(xml)
    rescue ::Ox::Error, NoMethodError, ArgumentError
      raise EvilEvents::XMLDeserializationError
    end
  end

  # @since 0.4.0
  register(:ox) { Ox }
end
