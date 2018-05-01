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
    require_relative 'system/type_manager'

    # @since 0.1.0
    extend Forwardable
    # @since 0.1.0
    include Mocking

    # @see EvilEvents::Core::System::Broadcaster
    #
    # @api private
    # @since 0.1.0
    def_delegators :broadcaster,
                   :emit,
                   :raw_emit,
                   :resolve_adapter,
                   :register_adapter,
                   :process_event_notification,
                   :restart_event_notifier

    # @see EvilEvents::Core::System::EventManager
    #
    # @api private
    # @since 0.1.0
    def_delegators :event_manager,
                   :observe,
                   :raw_observe,
                   :observe_list,
                   :conditional_observe,
                   :scoped_observe,
                   :observers,
                   :register_event_class,
                   :unregister_event_class,
                   :manager_of_event,
                   :manager_of_event_type,
                   :registered_events,
                   :resolve_event_class,
                   :resolve_event_object,
                   :managed_event?

    # @see EvilEvents::Core::System::EventBuilder
    #
    # @api private
    # @since 0.1.0
    def_delegators :event_builder,
                   :define_event_class,
                   :define_abstract_event_class,
                   :deserialize_from_json,
                   :deserialize_from_hash,
                   :deserialize_from_xml,
                   :deserialize_from_msgpack,
                   :serialize_to_json,
                   :serialize_to_hash,
                   :serialize_to_msgpack,
                   :serialize_to_xml

    # @see EvilEvents::Core::System::TypeManager
    #
    # @api private
    # @since 0.2.0
    def_delegators :type_manager,
                   :register_converter,
                   :resolve_type

    # @return [EvilEvents::Core::System::Broadcaster]
    #
    # @api private
    # @since 0.1.0
    attr_reader :broadcaster

    # @return [EvilEvents::Core::System::EventManager]
    #
    # @api private
    # @since 0.1.0
    attr_reader :event_manager

    # @return [EvilEvents::Core::System::TypeManager]
    #
    # @api private
    # @since 0.2.0
    attr_reader :type_manager

    # @return [EvilEvents::Core::System::EventBuilder]
    #
    # @api private
    # @since 0.4.0
    attr_reader :event_builder

    # @api private
    # @since 0.1.0
    def initialize
      @event_builder = EventBuilder.new
      @broadcaster   = Broadcaster.new
      @event_manager = EventManager.new
      @type_manager  = TypeManager.new
    end
  end
end
