# frozen_string_literal: true

module EvilEvents::Shared
  # @api public
  # @since 0.2.0
  class TypeConverter
    # @return [EvilEvents::Shared::TypeConverter::ConverterRegistry]
    #
    # @since 0.2.0
    attr_reader :registry

    # @since 0.2.0
    def initialize
      @registry = ConverterRegistry.new
    end

    # @param type_name [Symbol]
    # @param callable [Nil,Mixed]
    # @param convertion [Block]
    # @return void
    #
    # @see EvilEvents::Shared::TypeConverter::ConverterRegistry
    #
    # @api public
    # @since 0.2.0
    def register(type_name, &convertion)
      registry.register(type_name, &convertion)
    end

    # @param type_name [Symbol]
    # @param options [Hash]
    # @return [EvilEvents::Shared::Types::Any]
    #
    # @since 0.2.0
    def resolve(type_name, **options)
      registry.resolve(type_name).transform_to_type(**options)
    end
  end
end
