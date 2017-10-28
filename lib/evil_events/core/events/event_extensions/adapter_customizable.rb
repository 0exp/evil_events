# frozen_string_literal: true

module EvilEvents::Core::Events::EventExtensions
  # @api private
  # @since 0.1.0
  module AdapterCustomizable
    class << self
      # @param base_class [Class]
      #
      # @since 0.1.0
      def included(base_class)
        base_class.extend(ClassMethods)
      end
    end

    # @return [EvilEvents::Core::Broadcasting::Dispatcher::Dispatchable]
    #
    # @since 0.1.0
    def adapter
      self.class.adapter
    end

    # @return [EvilEvents::Core::Broadcasting::Dispatcher::Dispatchable]
    #
    # @since 0.1.0
    def adapter_name
      self.class.adapter_name
    end

    # @since 0.1.0
    module ClassMethods
      # @param identifier [Symbol, String]
      # @return [EvilEvents::Core::Broadcasting::Dispatcher::Dispatchable]
      #
      # @since 0.1.0
      def adapter(identifier = nil)
        @adapter_identifier = identifier if identifier
        EvilEvents::Core::Bootstrap[:event_system].resolve_adapter(adapter_name)
      end

      # @return [Symbol, String]
      #
      # @since 0.1.0
      def adapter_name
        @adapter_identifier || EvilEvents::Core::Bootstrap[:config].adapter.default
      end
    end
  end
end
