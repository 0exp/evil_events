# frozen_string_literal: true

# frozen_string_literal

class EvilEvents::Core::Events::Serializers
  # @api private
  # @since 0.4.0
  class Base
    # @param engine [Engines::Abstract]
    # @param config [GenericConfig]
    # @param packer [DataTransformer]
    # @param unpacker [DataTransformer]
    #
    # @api private
    # @since 0.4.0
    def initialize(engine, config, packer, unpacker)
      @engine   = engine
      @config   = config
      @packer   = packer
      @unpacker = unpacker
    end

    # @param event [EvilEvents::Core::Events::AbstractEvent]
    # @return [Object]
    #
    # @api private
    # @since 0.4.0
    def serialize(event)
      packer.call(event)
    end

    # @param data [Object]
    # @return [EvilEvents::Core::Events::AbstractEvent]
    #
    # @api private
    # @since 0.4.0
    def deserialize(data)
      unpacker.call(data)
    end

    private

    # @return [DataTransformer]
    #
    # @api private
    # @since 0.4.0
    attr_reader :packer

    # @return [DataTransformer]
    #
    # @api private
    # @since 0.4.0
    attr_reader :unpacker

    # @return [Engines::Abstract]
    #
    # @api private
    # @since 0.4.0
    attr_reader :engine

    # @return [GenericConfig]
    #
    # @api private
    # @since 0.4.0
    attr_reader :config
  end
end
