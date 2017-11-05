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
    # @since 0.2.0
    attr_reader :converters

    # @since 0.2.0
    def initialize
      @converters = EvilEvents::Shared::DependencyContainer.new
    end

    # @param type_name [Symbol]
    # @param convertion [proc]
    # @raise ArgumentError
    # @return void
    #
    # @api public
    # @since 0.2.0
    def register(type_name, &convertion)
      raise ArgumentError unless block_given?
      raise ArgumentError unless type_name.is_a?(Symbol)

      converters.register(type_name, Converter.new(convertion))
    end

    # @param type [Mixed]
    # @raise ConverterNotRegisteredError
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
