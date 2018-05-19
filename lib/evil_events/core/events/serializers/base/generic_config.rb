# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers::Base
  # @api private
  # @since 0.4.0
  class GenericConfig < Qonfig::DataSet
    setting :options
  end
end
