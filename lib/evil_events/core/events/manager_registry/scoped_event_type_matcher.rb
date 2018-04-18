# frozen_string_literal: true

class EvilEvents::Core::Events::ManagerRegistry
  # @api private
  # @since 0.4.0
  class ScopedEventTypeMatcher
    # @return [Regexp]
    #
    # @api private
    # @since 0.4.0
    attr_reader :pattern_matcher

    # @return [String]
    #
    # @api private
    # @since 0.4.0
    attr_reader :scope_pattern

    # @return [Integer,Float::INFINITY]
    #
    # @api private
    # @since 0.4.0
    attr_reader :scope_pattern_size

    # @param scope_pattern [String]
    # @raise [EvilEvents::ArgimentError]
    #
    # @api private
    # @since 0.4.0
    def initialize(scope_pattern)
      raise EvilEvents::ArgumentError unless scope_pattern.is_a?(String)

      @scope_pattern      = scope_pattern
      @scope_pattern_size = count_scope_pattern_size(scope_pattern)
      @pattern_matcher    = build_pattern_matcher(scope_pattern)
    end

    # @param event_type [String]
    # @return [Boolean]
    #
    # @api private
    # @since 0.4.0
    def match?(event_type)
      return false unless comparable_event_scope_sizes?(event_type)
      !!pattern_matcher.match(event_type)
    end

    private

    # @param event_type [String]
    # @return [Boolean]
    #
    # @api private
    # @since 0.4.0
    def comparable_event_scope_sizes?(event_type)
      return true unless scope_pattern_size.finite?
      scope_pattern_size == count_event_type_size(event_type)
    end

    # @param scope_pattern [String]
    # @return [Integer,Float::INFINITY]
    #
    # @api private
    # @since 0.4.0
    def count_scope_pattern_size(scope_pattern)
      return Float::INFINITY if scope_pattern == '#'
      return Float::INFINITY if scope_pattern.include?('.#')
      return Float::INFINITY if scope_pattern.include?('#.')
      return Float::INFINITY if scope_pattern.include?('.#.')

      scope_pattern.split('.').size
    end

    # @param event_type [String]
    # @return [Integer]
    #
    # @api private
    # @since 0.4.0
    def count_event_type_size(event_type)
      event_type.split('.').size
    end

    def build_pattern_matcher(scope_pattern)
      routing_parts  = scope_pattern.split('.')

      regexp_parts = routing_parts.each_with_object([]) do |routing_part, regexps|
        case routing_part
        when '*'
          regexps << { routing_part: routing_part, pattern: '.*\.' }
        when '#'
          if regexps.last && regexps.last[:routing_part] != '#' && regexps.last[:routing_part] != '*'
            regexps.last[:pattern] = regexps.last[:pattern][0..-3]
          end

          regexps << { routing_part: routing_part, pattern: '\.*.*' }
        else
          regexps << { routing_part: routing_part, pattern: Regexp.escape(routing_part) + '\.' }
        end
      end

      pattern_regexp = regexp_parts.map { |x| x[:pattern] }.join('')

      pattern_regexp = pattern_regexp[2..-1] if pattern_regexp[0..1] == '\.'
      pattern_regexp = pattern_regexp[0..-3] if pattern_regexp[-1] == '.' && pattern_regexp[-2] == "\\"

      Regexp.new('\A' + pattern_regexp + '\z')
    end
  end
end
