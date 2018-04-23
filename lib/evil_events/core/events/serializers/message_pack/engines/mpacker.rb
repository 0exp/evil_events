# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers::MessagePack::Engines
  # @api private
  # @since 0.4.0
  class Mpacker < EvilEvents::Core::Events::Serializers::Base::AbstractEngine
    # @api private
    # @since 0.4.0
    def initialize # TODO: options
      @factory  = ::MessagePack::Factory.new # TODO: configuration
      @packer   = @factory.packer
      @unpacker = @factory.unpacker
    end

    # @param serialization_state [Base::EventSerializationState]
    # @return [String]
    #
    # @since 0.4.0
    # @api private
    def dump(serialization_state)
      packer.pack(
        id:       serialization_state.id,
        type:     serialization_state.type,
        payload:  serialization_state.payload,
        metadata: serialization_state.metadata
      ).to_str
    end

    # @param message [String]
    # @raise [EvilEvents::MessagePackDeserializationErro]
    # @return [EventSerializationState]
    #
    # @since 0.4.0
    # @api private
    def load(message)
      begin
        event_data = unpacker.feed(message).unpack
      rescue ::MessagePack::UnpackError
        raise EvilEvents::MessagePackDeserializationErro
      end

      restore_serialization_state(
        id:       event_data['id'],
        type:     event_data['type'],
        payload:  symbolized_hash(event_data['payload']),
        metadata: symbolized_hash(event_data['metadata'])
      )
    end

    private

    # @return [::MessagePack::Factory]
    #
    # @api private
    # @since 0.4.0
    attr_reader :factory

    # @return [::MessagePack::Packer]
    #
    # @api private
    # @since 0.4.0
    attr_reader :packer

    # @return [::MessagePack::Unpacker]
    #
    # @api private
    # @since 0.4.0
    attr_reader :unpacker

    # @param hash [::Hash]
    # @return [::Hash]
    #
    # @since 0.4.0
    def symbolized_hash(hash)
      hash.each_pair.each_with_object({}) do |(key, value), result_hash|
        result_hash[key.to_sym] = value
      end
    end
  end

  # @since 0.4.0
  register(:mpacker) { Mpacker }
end
