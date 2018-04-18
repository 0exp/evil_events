# frozen_string_literal: true

class EvilEvents::Core::Events::ManagerRegistry
  # @api private
  # @since 0.4.0
  class ScopedEventTypeMatcher
    # @param scope_pattern [String]
    #
    # @api private
    # @since 0.4.0
    def initialize(scope_pattern)
      raise EvilEvents::ArgumentError unless scope_pattern.is_a?(String)
      @scope_pattern   = scope_pattern
      @pattern_matcher = build_pattern_matcher(scope_pattern)
    end

    # @param event_type [String]
    # @return [Boolean]
    #
    # @api private
    # @since 0.4.0
    def match?(event_type)
      parts_count   = event_type.split('.').size
      pattern_parts = if scope_pattern.include?('.#') || scope_pattern.include?('.#.') || scope_pattern.include?('#.') || scope_pattern == '#'
        nil
      else
        scope_pattern.split('.').size
      end

      if !!pattern_parts && pattern_parts != parts_count
        return false
      end

      !!pattern_matcher.match(event_type)
    end

    # @return [Regexp]
    #
    # @since 04.0
    attr_reader :pattern_matcher

    attr_reader :scope_pattern

    def build_pattern_matcher(scope_pattern)
      # NOTE: just for testing

      pattern_regexp = scope_pattern.split('.')
      pattern_regexp = pattern_regexp.map do |part|
        case part
        when '*' then '.*'
          { initial: '*', pattern: '.*' }
        when '#' then '\.*.*'
          { initial: '#', pattern: '\.*.*' }
        else
          { initial: part, pattern: Regexp.escape(part) }
        end
      end

      pattern_regexp = pattern_regexp.each_with_object([]) do |pattern, parts|
        case pattern[:initial]
        when '*'
          parts << { initial: '*', text: (pattern[:pattern] + '\.') }
        when '#'
          if parts.last && parts.last[:initial] != '#' && parts.last[:initial] != '*'
            parts.last[:text] = parts.last[:text][0..-3]
          end

          parts << { initial: '#', text: pattern[:pattern] }
        else
          parts << { initial: pattern[:pattern], text: (pattern[:pattern] + '\.') }
        end
      end

      pattern_regexp = pattern_regexp.map { |x| x[:text] }.join('')
      if pattern_regexp[0..1] == '\.'
        pattern_regexp = pattern_regexp[2..-1]
      end

      if pattern_regexp[-1] == '.' && pattern_regexp[-2] == "\\"
        pattern_regexp = pattern_regexp[0..-3]
      end

      Regexp.new('\A' + pattern_regexp + '\z')
    end
  end
end
