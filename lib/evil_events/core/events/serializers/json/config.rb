# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers
  class JSON
    # @api private
    # @since 0.4.0
    class Config < Base::GenericConfig
      setting :engine
    end
  end
end
