# frozen_string_literal: true

module EvilEvents::Core::Events::Notifier
  # @api private
  # @sicne 0.3.0
  module Builder
    class << self
      # @raise EvilEvents::UnknownNotifierTypeError
      # @return [Notifier::Abstract, Notifier::Sequential, Notifier::Worker]
      #
      # @api private
      # @since 0.3.0
      def build_notifier!
        case EvilEvents::Core::Bootstrap[:config].notifier.type
        when :sequential then build_sequential_notifier!
        when :worker     then build_worker_notifier!
        else
          raise EvilEvents::UnknownNotifierTypeError
        end
      end

      private

      # @return [Notifier::Sequential]
      #
      # @api private
      # @since 0.3.0
      def build_sequential_notifier!
        options = EvilEvents::Core::Bootstrap[:config].notifier.sequential.to_h
        Sequential.new(**options)
      end

      # @return [Notifier::Worker]
      #
      # @api private
      # @since 0.3.0
      def build_worker_notifier!
        options = EvilEvents::Core::Bootstrap[:config].notifier.worker.to_h
        Worker.new(**options)
      end
    end
  end
end
