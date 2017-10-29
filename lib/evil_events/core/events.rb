# frozen_string_literal: true

module EvilEvents::Core
  # @api private
  # @since 0.1.0
  module Events
    require_relative 'events/serializers'
    require_relative 'events/serializers/base'
    require_relative 'events/serializers/hash'
    require_relative 'events/serializers/json'
    require_relative 'events/event_extensions/type_aliasing'
    require_relative 'events/event_extensions/payloadable'
    require_relative 'events/event_extensions/payloadable/abstract_payload'
    require_relative 'events/event_extensions/manageable'
    require_relative 'events/event_extensions/adapter_customizable'
    require_relative 'events/event_extensions/observable'
    require_relative 'events/event_extensions/serializable'
    require_relative 'events/event_extensions/metadata_extendable'
    require_relative 'events/event_extensions/metadata_extendable/abstract_metadata'
    require_relative 'events/event_extensions/emittable'
    require_relative 'events/abstract_event'
    require_relative 'events/manager'
    require_relative 'events/manager/notifier'
    require_relative 'events/manager/subscriber_list'
    require_relative 'events/manager_factory'
    require_relative 'events/manager_registry'
    require_relative 'events/subscriber'
    require_relative 'events/subscriber/mixin'
    require_relative 'events/event_factory'
  end
end
