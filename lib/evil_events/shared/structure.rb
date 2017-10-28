# frozen_string_literal: true

module EvilEvents::Shared
  # @api public
  # @since 0.1.0
  class Structure < Dry::Struct
    class << self
      # @since 0.1.0
      alias_method :_native_attribute, :attribute

      # @param key [Symbol]
      # @param type [EvilEvents::Shared::Types::Any]
      #
      # @since 0.1.0
      def attribute(key, type = EvilEvents::Shared::Types::Any)
        _native_attribute(key, type)
      end
    end

    # NOTE: dry-struct API + dry-initializer API
    constructor_type :strict_with_defaults
  end
end
