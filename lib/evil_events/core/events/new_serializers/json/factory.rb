# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers
  class JSON
    # @api private
    # @since 0.4.0
    class Factory < AbstractFactory
      # @return [JSON::Config]
      #
      # @api private
      # @since 0.4.0
      def build_config
        settings = EvilEvents::Core::Bootstrap[:config].serializers.json
        Config.new(engine: settings.engine)
      end

      # @param config [JSON::Config]
      # @raise [EvilEvents::UnrecognizedSerializationEngineError]
      # @return [Base::AbstractEngine]
      #
      # @api private
      # @since 0.4.0
      def build_engine(config)
        case config.engine
        when :native then Engines::Native.new
        else
          raise EvilEvents::UnrecognizedSerializationEngine
        end
      end

      # @param engine [Base::AbstractEngine]
      # @param config [JSON::Config]
      # @return [JSON::Packer]
      #
      # @api private
      # @since 0.4.0
      def build_packer(engine, config)
        Packer.new(engine)
      end

      # @param engine [Base::AbstractEngine]
      # @param config [JSON::Config]
      # @return [JSON::Unpacker]
      #
      # @api private
      # @since 0.4.0
      def build_unpacker(engine, config)
        Unpacker.new(engine)
      end

      def create_adapter(engine, config, packer, unpacker)
        JSON.new(engine, config, packer, unpacker)
      end
    end
  end
end
