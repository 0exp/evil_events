# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers
  # @api private
  # @since 0.4.0
  Hash = Class.new(Base)

  # @since 0.4.0
  register(:hash, memoize: true) { Hash::Factory.new.create! }
end
