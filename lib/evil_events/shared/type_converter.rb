# frozen_string_literal: true

module EvilEvents::Shared
  # @api public
  # @since 0.2.0
  class TypeConverter
    # @return [EvilEvents::Shared::TypeConverter::ConverterRegistry]
    #
    # @api public
    # @since 0.2.0
    attr_reader :registry

    # @api public
    # @since 0.2.0
    def initialize
      @registry = ConverterRegistry.new
    end

    # @param type_name [Symbol]
    # @param coercer [Proc]
    # @return [EvilEvents::Shared::TypeConverter::Converter]
    #
    # @see EvilEvents::Shared::TypeConverter::ConverterRegistry
    #
    # @api public
    # @since 0.2.0
    def register(type_name, coercer)
      registry.register(type_name, coercer)
    end

    # @param type_name [Symbol]
    # @param options [Hash]
    # @return [EvilEvents::Shared::Types::Any]
    #
    # @see EvilEvents::Shared::TypeConverter::ConverterRegistry
    #
    # @api public
    # @since 0.2.0
    def resolve_type(type_name, **options)
      registry.resolve(type_name).transform_to_type(**options)
    end
  end
end
