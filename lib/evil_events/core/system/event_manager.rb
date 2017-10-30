# frozen_string_literal: true

class EvilEvents::Core::System
  # @api private
  # @since 0.1.0
  class EventManager
    # @return [EvilEvents::Core::Events::ManagerRegistry]
    #
    # @since 0.1.0
    attr_reader :manager_registry

    def initialize
      @manager_registry = EvilEvents::Core::Events::ManagerRegistry.new
    end

    # @param event_class [Class{Evilevents::Core::Events::AbstractEvent}]
    # @param raw_subscriber [Object]
    # @param delegator [String, Symbol, NilClass]
    # @return void
    #
    # @since 0.1.0
    def observe(event_class, raw_subscriber, delegator)
      manager_registry.manager_of_event(event_class)
                      .observe(raw_subscriber, delegator)
    end

    # @param event_type [String, Symbol]
    # @param raw_subscriber [Object]
    # @param delegator [String, Symbol, NilClass]
    # @return void
    #
    # @since 0.1.0
    def raw_observe(event_type, raw_subscriber, delegator)
      manager_registry.manager_of_event_type(event_type)
                      .observe(raw_subscriber, delegator)
    end

    # @param event_class [Class{EvilEvents::Core::Events::AbstractEvent}]
    # @return [Array<EvilEvents::Core::Events::Subscriber>]
    #
    # @since 0.1.0
    def observers(event_class)
      manager_registry.manager_of_event(event_class).subscribers
    end

    # @param event_class [Class{EvilEvents::Core::Events::AbstractEvent}]
    # @return void
    #
    # @since 0.1.0
    def register_event_class(event_class)
      manager_registry.register_with(event_class)
    end

    # @param event_class [Class{EvilEvents::Core::events::AbstractEvent}]
    # @return void
    #
    # @since 0.1.0
    def unregister_event_class(event_class)
      manager_registry.unregister_with(event_class)
    end

    # @param event [EvilEvents::Core::Events::AbstractEvent]
    # @return [EvilEvents::Core::Events::Manager]
    #
    # @since 0.1.0
    def manager_of_event(event)
      manager_registry.manager_of_event(event.class)
    end

    # @param event_type [String]
    # @return [EvilEvents::Core::Events::Manager]
    #
    # @since 0.1.0
    def manager_of_event_type(event_type)
      manager_registry.manager_of_event_type(event_type)
    end

    # @param event_type [String]
    # @option id [String,NilClass]
    # @option payload [Hash]
    # @option metadata [Hash]
    # @return [EvilEvents::Core::Events::AbstractEvent]
    #
    # @since 0.1.1
    def resolve_event_object(event_type, id: nil, payload: {}, metadata: {})
      manager_of_event_type(event_type).event_class.new(
        id: id, payload: payload, metadata: metadata
      )
    end

    # @param event_type [String]
    # @return [Class{EvilEvents::Core::Events::AbstractEvent}]
    #
    # @since 0.1.0
    def resolve_event_class(event_type)
      manager_of_event_type(event_type).event_class
    end

    # @param event_class [EvilEvents::Core::Events::AbstractEvent]
    # @return [Boolean]
    #
    # @since 0.1.0
    def managed_event?(event_class)
      manager_registry.managed_event?(event_class)
    end
  end
end
