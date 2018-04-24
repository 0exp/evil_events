# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers::MessagePack::Engines
  # @api private
  # @since 0.4.0
  class Mpacker < EvilEvents::Core::Events::Serializers::Base::AbstractEngine
    # @param config [EvilEvents::Core::Events::Serializers::MessagePack::Config]
    #
    # @api private
    # @since 0.4.0
    def initialize(config)
      configurator = config.mpacker.configurator
      raise EvilEvents::SerializationEngineError unless configurator.is_a?(Proc)
      @factory = ::MessagePack::Factory.new.tap { |factory| configurator.call(factory) }
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
        id:       event_data[:id],
        type:     event_data[:type],
        payload:  event_data[:payload],
        metadata: event_data[:metadata]
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
    def packer
      factory.packer
    end

    # @return [::MessagePack::Unpacker]
    #
    # @api private
    # @since 0.4.0
    def unpacker
      factory.unpacker(symbolize_keys: true)
    end
  end

  # @since 0.4.0
  register(:mpacker) { Mpacker }
end
