# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers
  class MessagePack
    # @api private
    # @since 0.4.0
    class Config < Base::GenericConfig
      setting :engine

      setting :mpacker do
        setting :configurator, ->(engine) {}
      end
    end
  end
end
