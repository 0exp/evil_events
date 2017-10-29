# frozen_string_literal: true

module EvilEvents::Core
  # @api private
  # @since 0.1.0
  class System
    require_relative 'system/mock'
    require_relative 'system/mocking'
    require_relative 'system/broadcaster'
    require_relative 'system/event_builder'
    require_relative 'system/event_manager'

    # @since 0.1.0
    extend Forwardable
    # @since 0.1.0
    include Mocking

    # @see EvilEvents::Core::System::Broadcaster
    # @since 0.1.0
    def_delegators :broadcaster,
                   :emit,
                   :raw_emit,
                   :resolve_adapter,
                   :register_adapter

    # @see EvilEvents::Core::System::EventManager
    # @since 0.1.0
    def_delegators :event_manager,
                   :observe,
                   :raw_observe,
                   :observers,
                   :register_event_class,
                   :unregister_event_class,
                   :manager_of_event,
                   :manager_of_event_type,
                   :resolve_event_class,
                   :resolve_event_object,
                   :managed_event?

    # @see EvilEvents::Core::System::EventBuilder
    # @since 0.1.0
    def_delegators 'EvilEvents::Core::System::EventBuilder',
                   :define_event_class,
                   :define_abstract_event_class,
                   :deserialize_from_json,
                   :deserialize_from_hash

    # @return [EvilEvents::Core::System::Broadcaster]
    #
    # @since 0.1.0
    attr_reader :broadcaster

    # @return [EvilEvents::Core::System::EventManager]
    #
    # @since 0.1.0
    attr_reader :event_manager

    # @since 0.1.0
    def initialize
      @broadcaster   = Broadcaster.new
      @event_manager = EventManager.new
    end
  end
end
