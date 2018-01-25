# frozen_string_literal: true

module EvilEvents::Core::Events::EventExtensions::Hookable
  # @api private
  # @since 0.3.0
  class OnErrorHook < AbstractHook
    # @param event [EvilEvents::Core::Events::AbstractEvent]
    # @param error [StandardError]
    # @return void
    #
    # @since 0.3.0
    def call(event, error)
      callable.call(event, error)
    end
  end
end
