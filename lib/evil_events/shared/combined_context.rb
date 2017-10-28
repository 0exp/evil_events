# frozen_string_literal: true

module EvilEvents
  module Shared
    # @example
    #  class EventStorage
    #    attr_reader :events
    #
    #    def initialize
    #      @events = []
    #    end
    #
    #    def store_event(event)
    #      @events << event
    #    end
    #  end
    #
    #  storage = EventStorage.new
    #  event   = 'test_event'
    #  clojure = proc { store_event(event) }
    #  context = EvilEvents::Shared::CombinedContext.new(storage, clojure)
    #
    #  storage.events # => []
    #
    #  context.evaluate
    #  storage.events # => ['test_event']
    #
    #  context.evaluate
    #  storage.events # => ['test_event', 'test_event']
    #
    # @since 0.1.0
    # @api public
    class CombinedContext < BasicObject
      # @since 0.1.0
      CombinedContextError = ::Class.new(::StandardError)
      # @since 0.1.0
      NonProcClojureObjectError = ::Class.new(CombinedContextError)

      # @return [Object]
      #
      # @since 0.1.0
      attr_reader :__required_context__

      # @return [Object]
      #
      # @since 0.1.0
      attr_reader :__outer_context__

      # @return [::Kernel]
      #
      # @since 0.1.0
      attr_reader :__kernel_context__

      # @return [Proc]
      #
      # @since 0.1.0
      attr_reader :__clojure__

      # @param required_context [Object]
      # @param clojure [Proc]
      #
      # @since 0.1.0
      def initialize(required_context, clojure)
        ::Kernel.raise NonProcClojureObjectError unless clojure.is_a?(::Proc)

        @__required_context__ = required_context
        @__outer_context__    = ::Kernel.eval('self', clojure.binding)
        @__kernel_context__   = ::Kernel
        @__clojure__          = clojure
      end

      # @return [Object]
      #
      # @see #method_missing
      #
      # @since 0.1.0
      def evaluate
        instance_eval(&__clojure__)
      end

      # @see #evaluate
      #
      # @since 0.1.0
      def method_missing(method_name, *arguments, &block)
        case
        when __outer_context__.respond_to?(method_name)
          __outer_context__.public_send(method_name, *arguments, &block)
        when __required_context__.respond_to?(method_name)
          __required_context__.public_send(method_name, *arguments, &block)
        when __kernel_context__.respond_to?(method_name)
          __kernel_context__.public_send(method_name, *arguments, &block)
        else
          super
        end
      end

      # @see #method_missing
      #
      # @since 0.1.0
      def respond_to_missing?(method_name, include_private = false)
        __outer_context__.respond_to?(method_name) ||
          __required_context__.respond_to?(method_name) ||
          __kernel_context__.respond_to?(method_name) || super
      end

      # @see #method_missing
      # @see #respond_to_missing?
      #
      # @since 0.1.0
      def method(method_name)
        case
        when __outer_context__.respond_to?(method_name)
          __outer_context__.method(method_name)
        when __required_context__.respond_to?(method_name)
          __required_context__.method(method_name)
        when __kernel_context__.respond_to?(method_name)
          __kernel_context__.method(method_name)
        else
          super
        end
      end
    end
  end
end
