# frozen_string_literal: true

class EvilEvents::Shared::TypeConverter
  # @api public
  # @since 0.2.0
  class TypeBuilder
    # @api public
    # @since 0.2.0
    def initialize
      @type_atom = Concurrent::Atom.new(EvilEvents::Shared::Types::Any)
    end

    # @param option [Symbol]
    # @param value [Mixed]
    # @return self
    #
    # @api public
    # @since 0.2.0
    def append(option, value)
      type_atom.swap do |type|
        case option
        when :default
          # NOTE: Dry::Types callable wrapper (see Dry::Types::Default::Callable#evaulate)
          default_value = value.is_a?(Proc) ? (-> (_type) { value.call }) : (proc { value })
          type.default(default_value)
        when :constructor
          type.constructor(value)
        else
          type
        end
      end

      self
    end

    # @return [EvilEvents::Shared::Types::Any]
    #
    # @api public
    # @since 0.2.0
    def result
      type_atom.value
    end

    private

    # @return [Concurrent::Atom<EvilEvents::Shared::Types::Any>]
    #
    # @since 0.2.0
    attr_reader :type_atom
  end
end
