# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers::Base
  # @api private
  # @since 0.4.0
  class AbstractFactory
    # @return [Base]
    #
    # @api private
    # @since 0.4.0
    def create!
      config = build_config
      engine = build_engine(config)

      packer   = build_packer(engine, config)
      unpacker = build_unpacker(engine, config)

      create_adapter(engine, config, packer, unpacker)
    end

    # @return [Base::GenericConfig]
    #
    # @api private
    # @since 0.4.0
    def build_config; end

    # @param config [Base::GenericConfig]
    # @return [Base::Engines::Abstract]
    #
    # @api private
    # @since 0.4.0
    def build_engine(config); end

    # @param engine [Base::Engines::Abstract]
    # @param config [Base::GenericConfig]
    # @return [Base::Dumper]
    #
    # @api private
    # @since 0.4.0
    def build_packer(engine, config); end

    # @param engine [Base::Engines::Abstract]
    # @param config [Base::GenericConfig]
    # @return [Base::Dumper]
    #
    # @api private
    # @since 0.4.0
    def build_unpacker(engine, config); end

    # @param engine [Base::AbstractEngine]
    # @param config [Base::GenericConfig]
    # @param packer [Base::DataTransformer]
    # @param unpacker [Base::DataTransformer]
    # @return [Base]
    #
    # @api private
    # @since 0.4.0
    def create_adapter(engine, config, packer, unpacker); end
  end
end
