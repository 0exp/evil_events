# frozen_string_literal: true

module EvilEvents::Shared
  # @api public
  # @since 0.1.0
  module Types
    Dry::Types.load_extensions(:maybe)
    include Dry::Types.module
  end
end
