# frozen_string_literal: true

module EvilEvents::Shared
  # @api public
  # @since 0.1.0
  class Logger < ::Logger
    # @since 0.1.0
    def initialize(*, **)
      super
      self.level = ::Logger::INFO
    end
  end
end
