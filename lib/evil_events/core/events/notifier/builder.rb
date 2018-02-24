# frozen_string_literal: true

module EvilEvents::Core::Events::Notifier
  # @api private
  # @sicne 0.3.0
  module Builder
    # @api public
    # @since 0.3.0
    BuilderError = Class.new(EvilEvents::Core::Error)

    # @api public
    # @since 0.3.0
    UnknownNotifierTypeError = Class.new(BuilderError)

    class << self
      # @param type [Symbol]
      # @param options [Hash]
      # @raise UnknownNotifierTypeError
      #
      # @api private
      # @since 0.3.0
      def build_notifier!
        case EvilEvents::Core::Bootstrap[:config].notifier.type
        when :sequential then build_sequential_notifier!
        when :worker     then build_worker_notifier!
        else
          raise UnknownNotifierTypeError
        end
      end

      private

      # @param type [Symbol]
      # @param options [Hash]
      #
      # @api private
      # @since 0.3.0
      def build_sequential_notifier!
        options = EvilEvents::Core::Bootstrap[:config].notifier.sequential.to_h
        Sequential.new(**options)
      end

      # @param type [Symbol]
      # @param options [Hash]
      #
      # @api private
      # @since 0.3.0
      def build_worker_notifier!(**options)
        options = EvilEvents::Core::Bootstrap[:config].notifier.worker.to_h
        Worker.new(**options)
      end
    end
  end
end
