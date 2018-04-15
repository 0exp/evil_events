# frozen_string_literal: true

# @api public
# @since 0.1.0
class EvilEvents::Core::System
  # @see EvilEvents::Core::System
  # @api public
  # @since 0.1.0
  class Mock
    # @see EvilEvents::Core::System
    # @since 0.1.0
    attr_reader :broadcaster

    # @see EvilEvents::Core::System
    # @since 0.1.0
    attr_reader :event_manager

    # @see EvilEvents::Core::System
    # @since 0.1.0
    def observe(event_class, raw_subscriber, delegator); end

    # @see EvilEvents::Core::System
    # @since 0.1.0
    def raw_observe(event_type, raw_subscriber, delegator); end

    # @see EvilEvents::Core::System
    # @since 0.2.0
    def observe_list(event_pattern, raw_subscriber, delegator); end

    # @see EvilEvents::Core::System
    # @since 0.2.0
    def conditional_observe(event_condition, raw_subscriber, delegator); end

    # @see EvilEvents::Core::System
    # @since 0.1.0
    def observers(event_class); end

    # @see EvilEvents::Core::System
    # @since 0.1.0
    def emit(event, adapter: nil); end

    # @see EvilEvents::Core::System
    # @since 0.1.0
    def raw_emit(event_type, id: nil, payload: {}, metadata: {}, adapter: nil); end

    # @see EvilEvents::Core::System
    # @since 0.1.0
    def resolve_adapter(adapter_name); end

    # @see EvilEvents::Core::System
    # @since 0.1.0
    def register_adapter(adapter_name, adapter_object); end

    # @see EvilEvents::Core::System
    # @since 0.1.0
    def register_event_class(event_class); end

    # @see EvilEvents::Core::System
    # @since 0.1.0
    def unregister_event_class(event_class); end

    # @see EvilEvents::Core::System
    # @since 0.1.0
    def manager_of_event(event); end

    # @see EvilEvents::Core::System
    # @since 0.1.0
    def manager_of_event_type(event_type); end

    # @see EvilEvents::Core::System
    # @since 0.1.0
    def resolve_event_object(event_type, id: nil, payload: {}, metadata: {}); end

    # @see EvilEvents::Core::System
    # @since 0.1.0
    def resolve_event_class(event_type); end

    # @see EvilEvents::Core::System
    # @since 0.1.0
    def define_event_class(event_type, &event_class_definitions); end

    # @see EvilEvents::Core::System
    # @since 0.1.0
    def define_abstract_event_class(event_type); end

    # @see EvilEvents::Core::System
    # @since 0.1.0
    def deserialize_from_json(serialized_event); end

    # @see EvilEvents::Core::System
    # @since 0.1.0
    def deserialize_from_hash(serialized_event); end

    # @see EvilEvents::Core::System
    # @since 0.4.0
    def deserialize_from_xml(serialized_event); end

    # @see EvilEvents::Core::System
    # @since 0.1.0
    def managed_event?(event_class); end

    # @see EvilEvents::Core::System
    # @since 0.2.0
    def register_converter(type, coercer); end

    # @see EvilEvents::Core::System
    # @since 0.2.0
    def resolve_type(type, **options); end

    # @see EvilEvents::Core::System
    # @since 0.2.0
    def registered_events; end

    # @see EvilEvents::Core::System
    # @since 0.3.0
    def process_event_notification(manager, event); end

    # @see EvilEvents::Core::System
    def restart_event_notifier; end
  end
end
