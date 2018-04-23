# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers
  class MessagePack
    # @api private
    # @since 0.4.0
    class Config < Base::GenericConfig
      option :engine

      # @note Mpacker Configuration Proc
      # @see [EvilEvents::Core::Config]
      option :mpacker
    end
  end
end
