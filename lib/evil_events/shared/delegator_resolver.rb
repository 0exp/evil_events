# frozen_string_literal: true

module EvilEvents::Shared
  # @example
  #  DelegatorResolver.new(-> { 'test' }).delegator # => 'test'
  #  DelegatorResolver.new('test') # => InvalidProcAttributeError
  #
  # @since 0.1.0
  # @api public
  class DelegatorResolver
    # @since 0.1.0
    DelegatorResolverError = Class.new(StandardError)
    # @since 0.1.0
    InvalidProcAttributeError = Class.new(DelegatorResolverError)

    # @return [Proc]
    #
    # @since 0.1.0
    attr_reader :method_name_resolver

    # @param method_name_resolver [Proc]
    #
    # @since 0.1.0
    def initialize(method_name_resolver)
      raise InvalidProcAttributeError unless method_name_resolver.is_a?(Proc)
      @method_name_resolver = method_name_resolver
    end

    # @return [String, Symbol]
    #
    # @since 0.1.0
    def delegator
      @delegator ||= method_name_resolver.call
    end
  end
end
