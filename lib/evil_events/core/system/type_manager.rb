# frozen_string_literal: true

class EvilEvents::Core::System
  # @api private
  # @since 0.2.0
  class TypeManager
    # @return [EvilEvents::Shared::TypeConverter]
    #
    # @since 0.2.0
    attr_reader :converter

    # @since 0.2.0
    def initialize
      @converter = EvilEvents::Shared::TypeConverter.new
    end

    # @param type [Symbol]
    # @param coercer [Proc]
    # @return [EvilEvents::Shared::TypeConverter::Converter]
    #
    # @since 0.2.0
    def register_converter(type, coercer)
      converter.register(type, coercer)
    end

    # @param type [Symbol]
    # @param options [Hash]
    # @return [EvilEvents::Shared::Types::Any]
    #
    # @since 0.2.0
    def resolve_type(type, **options)
      converter.resolve_type(type, **options)
    end
  end
end
