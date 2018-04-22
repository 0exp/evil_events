# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers::Base
  # @api private
  # @since 0.4.0
  class AbstractEngine
    # @param data [Object]
    # @return [Object]
    #
    # @api private
    # @since 0.4.0
    def dump(data); end

    # @param data [Object]
    # @return [Object]
    #
    # @api private
    # @since 0.4.0
    def load(data); end
  end
end
