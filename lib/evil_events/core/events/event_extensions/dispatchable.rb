# frozen_string_literal: true

module EvilEvents::Core::Events::EventExtensions
  # @api private
  # @since 0.4.0
  module Dispatchable
    class << self
      # @param base_class [Class{AbstractEvent}]
      #
      # @api private
      # @since 0.4.0
      def included(base_class)
        base_class.extend(ClassMethods)
      end
    end

    # @return [EvilEvents::Core::Broadcasting::Dispatcher::Dispatchable]
    #
    # @since 0.4.0
    def adapter
      self.class.adapter
    end

    # @return [EvilEvents::Core::Broadcasting::Dispatcher::Dispatchable]
    #
    # @since 0.4.0
    def adapter_name
      self.class.adapter_name
    end

    # @return void
    #
    # @api public
    # @since 0.4.0
    def emit!(adapter: nil)
      EvilEvents::Core::Bootstrap[:event_system].emit(self, adapter: adapter)
    end

    # @since 0.4.0
    module ClassMethods
      # @param identifier [Symbol, String]
      # @return [EvilEvents::Core::Broadcasting::Dispatcher::Dispatchable]
      #
      # @since 0.4.0
      def adapter(identifier = nil)
        @adapter_identifier = identifier if identifier
        EvilEvents::Core::Bootstrap[:event_system].resolve_adapter(adapter_name)
      end

      # @return [Symbol, String]
      #
      # @since 0.4.0
      def adapter_name
        @adapter_identifier || EvilEvents::Core::Bootstrap[:config].adapter.default
      end

      # @option id [NilClass, Object]
      # @option payload [Hash]
      # @option metadata [Hash]
      # @return void
      #
      # @see EvilEvents::Core::Events::AbstractEvent#initialize
      # @see EvilEvents::Core::Events::EventExtensions::Emittable#emit!
      #
      # @api public
      # @since 0.4.0
      def emit!(id: nil, payload: {}, metadata: {}, adapter: nil)
        new(id: id, payload: payload, metadata: metadata).emit!(adapter: adapter)
      end
    end
  end
end
