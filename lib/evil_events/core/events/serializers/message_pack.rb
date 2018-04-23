# frozen_string_literal: true

# frozen_string_# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers
  # @api private
  # @since 0.4.0
  MessagePack = Class.new(Base)

  # @since 0.4.0
  register(:msgpack, memoize: true) { MessagePack::Factory.new.create! }
end
