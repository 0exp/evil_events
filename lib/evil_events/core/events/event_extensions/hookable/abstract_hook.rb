# frozen_string_literal: true

module EvilEvents::Core::Events::EventExtensions::Hookable
  # @api private
  # @since 0.3.0
  class AbstractHook
    # @return [#call]
    #
    # @since 0.3.0
    attr_reader :callable

    # @param callable [#call]
    #
    # @since 0.3.0
    def initialize(callable)
      @callable = callable
    end

    # @param event [EvilEvents::Core::Events::AbstractEvent]
    # @return void
    #
    # @since 0.3.0
    def call(event)
      callable.call(event)
    end
  end
end
