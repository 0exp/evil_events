# frozen_string_literal: true

module EvilEvents::Core::Events::EventExtensions::Hookable
  # @api private
  # @since 0.3.0
  class AfterEmitHook < AbstractHook
    # @!method call(source)
    #   @param source [EvilEvents::Core::Events::AbstractEvent]
    #   @return void
  end
end
