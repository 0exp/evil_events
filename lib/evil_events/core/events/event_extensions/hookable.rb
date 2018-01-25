# frozen_string_literal: true

module EvilEvents::Core::Events::EventExtensions
  # @api private
  # @since 0.3.0
  module Hookable
    class << self
      # @param base_class [Class]
      #
      # @since 0.3.0
      def included(base_class)
        base_class.extend(ClassMethods)
      end
    end

    # @param error [StandardError]
    #
    # @api private
    # @since 0.3.0
    def __call_on_error_hooks__(error)
      self.class.__on_error_hooks__.each do |hook|
        hook.call(self, error)
      end
    end

    # @api private
    # @since 0.3.0
    def __call_before_hooks__
      self.class.__before_emit_hooks__.each do |hook|
        hook.call(self)
      end
    end

    # @api private
    # @since 0.3.0
    def __call_after_hooks__
      self.class.__after_emit_hooks__.each do |hook|
        hook.call(self)
      end
    end

    # @since 0.3.0
    module ClassMethods
      # @param hook [#call]
      #
      # @api public
      # @since 0.3.0
      def before_emit(hook)
        __before_emit_hooks__ << BeforeEmitHook.new(hook)
      end

      # @param hook [#call]
      #
      # @api public
      # @since 0.3.0
      def after_emit(hook)
        __after_emit_hooks__ << AfterEmitHook.new(hook)
      end

      # @param hook [#call]
      #
      # @api public
      # @since 0.3.0
      def on_error(hook)
        __on_error_hooks__ << OnErrorHook.new(hook)
      end

      # @return [Concurrent::Array<BeforeHook>]
      #
      # @api private
      # @since 0.3.0
      def __before_emit_hooks__
        @__before_emit_hooks__ ||= Concurrent::Array.new
      end

      # @return [Concurrent::Array<AfterHook>]
      #
      # @api private
      # @since 0.3.0
      def __after_emit_hooks__
        @__after_emit_hooks__ ||= Concurrent::Array.new
      end

      # @return [Concurrent::Array<OnErrorHook>]
      #
      # @api private
      # @since 0.3.0
      def __on_error_hooks__
        @__on_error_hooks__ ||= Concurrent::Array.new
      end
    end
  end
end
