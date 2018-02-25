# frozen_string_literal: true

class EvilEvents::Shared::TypeConverter
  # @api public
  # @since 0.2.0
  class ConverterRegistry
    # @since 0.2.0
    ConverterRegistryError = Class.new(StandardError)
    # @since 0.2.0
    ConverterNotRegisteredError = Class.new(ConverterRegistryError)

    # @return [Coucnrrent::Map]
    #
    # @api public
    # @since 0.2.0
    attr_reader :converters

    # @api public
    # @since 0.2.0
    def initialize
      @converters = EvilEvents::Shared::DependencyContainer.new
    end

    # @param type_name [Symbol]
    # @param coercer [Proc]
    # @raise [ArgumentError]
    # @return [Converter]
    #
    # @api public
    # @since 0.2.0
    def register(type_name, coercer)
      raise ArgumentError unless type_name.is_a?(Symbol)
      raise ArgumentError unless coercer.is_a?(Proc)

      Converter.new(coercer).tap do |converter|
        converters.register(type_name, converter)
      end
    end

    # @param type [Mixed]
    # @raise [ConverterNotRegisteredError]
    # @return [Mixed]
    #
    # @api public
    # @since 0.2.0
    def resolve(type)
      converters[type]
    end
    alias_method :[], :resolve
  end
end
