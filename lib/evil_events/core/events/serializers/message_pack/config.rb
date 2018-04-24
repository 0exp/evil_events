# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers
  class MessagePack
    # @api private
    # @since 0.4.0
    class Config < Base::GenericConfig
      configure do
        setting :engine, reader: true

        setting :mpacker, reader: true do
          setting :configurator, reader: true
        end
      end
    end
  end
end
