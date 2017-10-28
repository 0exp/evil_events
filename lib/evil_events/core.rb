# frozen_string_literal: true

module EvilEvents
  # @api private
  # @since 0.1.0
  module Core
    require_relative 'core/activity_logger'
    require_relative 'core/broadcasting'
    require_relative 'core/events'
    require_relative 'core/config'
    require_relative 'core/system'
    require_relative 'core/bootstrap'
  end
end
