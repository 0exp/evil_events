# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers
  class Hash
    # @api private
    # @since 0.4.0
    class Config < Base::GenericConfig
      configure { setting :engine, reader: true }
    end
  end
end
