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
        settings = EvilEvents::Core::Bootstrap[:config].settings.serializers.xml

        Config.new.tap do |config|
          config.settings.engine = settings.engine
        end
      end

      # @param config [XML::Config]
      # @raise [EvilEvents::UnrecognizedSerializationEngineError]
      # @return [Base::AbstractEngine]
      #
      # @api private
      # @since 0.4.0
      def build_engine(config)
        Engines.resolve(config.settings.engine).new(config)
      rescue Dry::Container::Error
        raise EvilEvents::UnrecognizedSerializationEngineError
      end

      # @param engine [Base::AbstractEngine]
      # @param config [XML::Config]
      # @return [XML::Packer]
      #
      # @api private
      # @since 0.4.0
      def build_packer(engine, _config)
        Packer.new(engine)
      end

      # @param engine [Base::AbstractEngine]
      # @param config [XML::Config]
      # @return [XML::Unpacker]
      #
      # @api private
      # @since 0.4.0
      def build_unpacker(engine, _config)
        Unpacker.new(engine)
      end

      # @param engine [Base::AbstractEngine]
      # @param config [XML::Config]
      # @param packer [XML::Packer]
      # @param unpacker [XML::Unpacker]
      # @return [XML]
      #
      # @api private
      # @since 0.4.0
      def create_adapter(engine, config, packer, unpacker)
        XML.new(engine, config, packer, unpacker)
      end
    end
  end
end
