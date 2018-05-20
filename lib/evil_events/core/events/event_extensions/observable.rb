# frozen_string_literal: true

module EvilEvents::Core::Events::EventExtensions
  # @api private
  # @since 0.1.0
  module Observable
    class << self
      # @param base_class [Class]
      #
      # @since 0.1.0
      def included(base_class)
        base_class.extend(ClassMethods)
      end
    end

    # @return [Array<EvilEvents::Core::Events::Subscriber>]
    #
    # @since 0.1.0
    def observers
      self.class.observers
    end
    alias_method :subscribers, :observers

    # @since 0.1.0
    module ClassMethods
      # @param raw_subscriber [Object]
      # @param delegator [Symbol, String, NilClass]
      #
      # @since 0.1.0
      def observe(raw_subscriber, delegator: nil)
        EvilEvents::Core::Bootstrap[:event_system].observe(self, raw_subscriber, delegator)
      end

      # @param delegator [Symbol, String, NilClass]
      #
      # @since 0.1.0
      def default_delegator(delegator = nil)
        @default_delegator = delegator if delegator
        @default_delegator || begin
          EvilEvents::Core::Bootstrap[:config].settings.subscriber.default_delegator
        end
      end

      # @return [Array]
      #
      # @since 0.1.0
      def observers
        EvilEvents::Core::Bootstrap[:event_system].observers(self)
      end
      alias_method :subscribers, :observers
    end
  end
end
