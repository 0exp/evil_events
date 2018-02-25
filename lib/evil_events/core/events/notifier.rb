# frozen_string_literal: true

# @api private
# @since 0.3.0
module EvilEvents::Core::Events::Notifier
  # @api public
  # @since 0.3.0
  NotifierError = Class.new(EvilEvents::Core::Error)

  # @api public
  # @since 0.3.0
  class FailedSubscribersError < NotifierError
    # @since 0.3.0
    extend Forwardable

    # @since 0.3.0
    def_delegators :errors_stack, :<<, :empty?

    # @return [Concurrent::Array]
    #
    # @api public
    # @since 0.3.0
    attr_reader :errors_stack

    # @param message [NilClass, String]
    #
    # @since 0.3.0
    def initialize(message = nil)
      @errors_stack = Concurrent::Array.new
      super
    end
  end
end
