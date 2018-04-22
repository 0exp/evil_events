# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers
  class XML
    # @api private
    # @since 0.4.0
    class Config < Base::GenericConfig
      # NOTE: name of engine
      #   Supported: :native
      option :engine
    end
  end
end
