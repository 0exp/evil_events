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
        options = EvilEvents::Core::Bootstrap[:config].settings.serializers.json
        Config.new.tap { |conf| conf.settings.options = options }
      end

      # @param config [JSON::Config]
      # @raise [EvilEvents::UnrecognizedSerializationEngineError]
      # @return [Base::AbstractEngine]
      #
      # @api private
      # @since 0.4.0
      def build_engine(config)
        Engines.resolve(config.settings.options[:engine]).new(config)
      rescue Dry::Container::Error
        raise EvilEvents::UnrecognizedSerializationEngineError
      end

      # @param engine [Base::AbstractEngine]
      # @param config [JSON::Config]
      # @return [JSON::Packer]
      #
      # @api private
      # @since 0.4.0
      def build_packer(engine, _config)
        Packer.new(engine)
      end

      # @param engine [Base::AbstractEngine]
      # @param config [JSON::Config]
      # @return [JSON::Unpacker]
      #
      # @api private
      # @since 0.4.0
      def build_unpacker(engine, _config)
        Unpacker.new(engine)
      end

      # @param engine [Base::AbstractEngine]
      # @param config [JSON::Config]
      # @param packer [JSON::Packer]
      # @param unpacker [JSON::Unpacker]
      # @return [JSON]
      #
      # @api private
      # @since 0.4.0
      def create_adapter(engine, config, packer, unpacker)
        JSON.new(engine, config, packer, unpacker)
      end
    end
  end
end
