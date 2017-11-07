# frozen_string_literal: true

class EvilEvents::Shared::TypeConverter
  # @api public
  # @since 0.2.0
  class Converter
    # @return [Proc]
    #
    # @api public
    # @since 0.2.0
    attr_reader :coercer

    # @param coercer [Proc]
    #
    # @api public
    # @since 0.2.0
    def initialize(coercer)
      raise ArgumentError unless coercer.is_a?(Proc)

      @coercer = coercer
    end

    # @param value [Mixed]
    # @return [Mixed]
    #
    # @api public
    # @since 0.2.0
    def convert(value)
      coercer.call(value)
    end

    # @option :default [Mixed]
    # @return [EvilEvents::Shared::Types::Any]
    #
    # @see EvilEvents::Shared::TypeConverter::TypeBuilder
    #
    # @since 0.2.0
    def transform_to_type(**options)
      TypeBuilder.new.tap do |builder|
        builder.append(:constructor, coercer)
        builder.append(:default, options[:default]) if options.key?(:default)
      end.result
    end
  end
end
