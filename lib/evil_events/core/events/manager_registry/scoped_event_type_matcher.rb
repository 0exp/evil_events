# frozen_string_literal: true

class EvilEvents::Core::Events::ManagerRegistry
  # @api private
  # @since 0.4.0
  class ScopedEventTypeMatcher
    # @return [String]
    #
    # @since 0.4.0
    PART_SPLITTER = '.'

    # @return [String]
    #
    # @since 0.4.0
    GENERIC_PART_PATTERN = '*'

    # @param scope_pattern [String]
    #
    # @api private
    # @since 0.4.0
    def initialize(scope_pattern)
      raise EvilEvents::ArgumentError unless scope_pattern.is_a?(String)

      @scope_pattern = scope_pattern
      @scope_parts   = scope_pattern.split(PART_SPLITTER)
    end

    # @param event_type [String]
    # @return [Boolean]
    #
    # @api private
    # @since 0.4.0
    def match?(event_type)
      return true if scope_pattern == event_type
      event_parts = event_type.split(PART_SPLITTER)
      return false if event_parts.size != scope_parts.size

      scope_parts.each_with_index do |scope_part, part_position|
        next if scope_part == GENERIC_PART_PATTERN
        next if event_parts[part_position] == scope_part
        return false
      end

      true
    end

    private

    # @return [Array<String>]
    #
    # @api private
    # @since 0.4.0
    attr_reader :scope_parts

    # @return [String]
    #
    # @api private
    # @since 0.4.0
    attr_reader :scope_pattern
  end
end
