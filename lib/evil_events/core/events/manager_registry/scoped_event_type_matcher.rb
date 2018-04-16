# frozen_string_literal: true

class EvilEvents::Core::Events::ManagerRegistry
  # @api private
  # @since 0.4.0
  class ScopedEventTypeMatcher
    # @param scoped_event_type [String]
    #
    # @api private
    # @since 0.4.0
    def initialize(scoped_event_type)
      @scoped_event_type = scoped_event_type
    end

    # @param event_type [String]
    # @return [Boolean]
    #
    # @api private
    # @since 0.4.0
    def match?(event_type)
    end

    private

    # @return [Regexp]
    #
    # @api private
    # @since 0.4.0
    attr_reader :scoped_event_type
  end
end
