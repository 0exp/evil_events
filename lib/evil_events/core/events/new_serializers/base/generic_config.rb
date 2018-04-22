# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers::Base
  # @api private
  # @since 0.4.0
  class GenericConfig < EvilEvents::Shared::Structure
    class << self
      # @since 0.4.0
      alias_method :option, :attribute
    end
  end
end
