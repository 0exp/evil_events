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

    # @param source [Object]
    # @return void
    #
    # @since 0.3.0
    def call(source)
      callable.call(source)
    end
  end
end
