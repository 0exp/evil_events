# frozen_string_literal: true

# frozen_string_# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers
  # @api private
  # @since 0.4.0
  XML = Class.new(Base)

  # @since 0.4.0
  register(:xml, memoize: true) { XML::Factory.new.create! }
end
