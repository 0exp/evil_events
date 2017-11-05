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
    # @param block [Block]
    # @return void
    #
    # @api private
    # @since 0.2.0
    def register_converter(type, &block)
      converter.register(type, &block)
    end

    # @param type [Symbol]
    # @param options [Hash]
    def resolve_type(type, **options)
      converter.resolve(type, **options)
    end
  end
end
