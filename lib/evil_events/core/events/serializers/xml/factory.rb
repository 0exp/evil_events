# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers
  class XML
    # @api private
    # @since 0.4.0
    class Factory < AbstractFactory
      # @return [XML::Config]
      #
      # @api private
      # @since 0.4.0
      def build_config
        settings = EvilEvents::Core::Bootstrap[:config].serializers.xml
        Config.new(engine: settings.engine)
      end

      # @param config [XML::Config]
      # @raise [EvilEvents::UnrecognizedSerializationEngineError]
      # @return [Base::AbstractEngine]
      #
      # @api private
      # @since 0.4.0
      def build_engine(config)
        Engines.resolve(config.engine).new
      rescue Dry::Container::Error
        raise EvilEvents::UnrecognizedSerializationEngine
      end

      # @param engine [Base::AbstractEngine]
      # @param config [XML::Config]
      # @return [XML::Packer]
      #
      # @api private
      # @since 0.4.0
      def build_packer(engine, config)
        Packer.new(engine)
      end

      # @param engine [Base::AbstractEngine]
      # @param config [XML::Config]
      # @return [XML::Unpacker]
      #
      # @api private
      # @since 0.4.0
      def build_unpacker(engine, config)
        Unpacker.new(engine)
      end

      def create_adapter(engine, config, packer, unpacker)
        XML.new(engine, config, packer, unpacker)
      end
    end
  end
end
