# frozen_string_literal: true

class EvilEvents::Shared::TypeConverter
  # @api public
  # @since 0.2.0
  class Converter
    # @since 0.2.0
    attr_reader :convertion_proc

    # @param type [Symbol]
    # @param convertion_proc [proc]
    #
    # @since 0.2.0
    def initialize(convertion_proc)
      @convertion_proc = convertion_proc
    end

    # @param value
    def convert(value)
      convertion_proc.call(value)
    end

    # @option :default [Mixed]
    #
    # @since 0.2.0
    def transform_to_type(**options)
      TypeBuilder.new.tap do |builder|
        builder.append(:constructor, convertion_proc)
        builder.append(:default, options[:default]) if options.key?(:default)
      end.result
    end
  end
end
