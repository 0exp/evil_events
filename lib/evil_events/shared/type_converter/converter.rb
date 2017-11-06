# frozen_string_literal: true

class EvilEvents::Shared::TypeConverter
  # @api public
  # @since 0.2.0
  class Converter
    # @since 0.2.0
    attr_reader :coercer

    # @param coercer [proc]
    #
    # @since 0.2.0
    def initialize(coercer)
      raise ArgumentError unless coercer.is_a?(Proc)

      @coercer = coercer
    end

    # @param value
    def convert(value)
      coercer.call(value)
    end

    # @option :default [Mixed]
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
