# frozen_string_literal: true

module EvilEvents::Core::Events
  # @api private
  # @since 0.1.0
  class ManagerRegistry
    # @since 0.1.0
    extend Forwardable

    # @since 0.1.0
    def_delegators :managers, :empty?, :size

    # @return [Concurrent::Map]
    #
    # @since 0.1.0
    attr_reader :managers

    # @since 0.1.0
    def initialize
      @managers = Concurrent::Map.new
    end

    # @param event_class [Class{EvilEvents::Core::Events::AbstractEvent}]
    # @raise [EvilEvents::NonManagedEventClassError]
    # @return [EvilEvents::Core::Events::Manager]
    #
    # @since 0.1.0
    def manager_of_event(event_class)
      # NOTE: raise exceptions to simplify runtime problems
      managers[event_class] || (raise EvilEvents::NonManagedEventClassError)
    end

    # @param event_type [String]
    # @return [EvilEvents::Core::Events::Manager]
    # @see manager_of_event
    #
    # @since 0.1.0
    def manager_of_event_type(event_type)
      event_class = managed_events.find do |managed_event|
        managed_event.type == event_type
      end

      manager_of_event(event_class)
    end

    # @param scoped_event_type [String]
    # @raise [EvilEvents::NonManagedEventClassError]
    # @return [Array<EvilEvents::Core::Events::Manager>]
    #
    # @api private
    # @since 0.4.0
    def managers_of_scoped_event_type(scoped_event_type)
      scope_matcher = ScopedEventTypeMatcher.new(scoped_event_type)

      event_classes = managed_events.select do |managed_event|
        scope_matcher.match?(managed_event.type)
      end

      event_classes.map { |event_class| manager_of_event(event_class) }
    end

    # @param event_pattern [Regexp]
    # @return [Array<EvilEvents::Core::Events::Manager>]
    #
    # @since 0.2.0
    def managers_of_event_pattern(event_pattern)
      event_classes = managed_events.select do |managed_event|
        managed_event.type.match(event_pattern)
      end

      event_classes.map { |event_class| manager_of_event(event_class) }
    end

    # @param event_condition [Proc]
    # @return [Array<EvilEvents::Core::Event::Manager>]
    #
    # @since 0.2.0
    def managers_of_event_condition(event_condition)
      # rubocop:disable Style/InverseMethods
      event_classes = managed_events.select do |managed_event|
        !!event_condition.call(managed_event.type)
      end
      # rubocop:enable Style/InverseMethods

      event_classes.map { |event_class| manager_of_event(event_class) }
    end

    # @param manager [EvilEvents::Core::Events::Manager]
    # @raise [EvilEvents::IncorrectManagerObjectError]
    # @raise [EvilEvents::AlreadyManagedEventClassError]
    # @return void
    #
    # @since 0.1.0
    def register(manager)
      unless manager.is_a?(EvilEvents::Core::Events::Manager)
        raise EvilEvents::IncorrectManagerObjectError
      end

      if potential_manager_duplicate?(manager) || !managed_event_type?(manager.event_type)
        managers[manager.event_class] = manager
      else
        raise EvilEvents::AlreadyManagedEventClassError
      end
    end

    # @param event_class [Class{EvilEvents::Core::Events::AbstractEvent}]
    # @return void
    # @see register
    #
    # @since 0.1.0
    def register_with(event_class)
      register(ManagerFactory.create(event_class))
    end

    # @param manager [EvilEvents::Core::Events::Manager]
    # @return void
    #
    # @since 0.1.0
    def unregister(manager)
      managers.delete_pair(manager.event_class, manager)
    end

    # @param event_class [Class{EvilEvents::Core::Events::AbstractEvent}]
    # @return void
    #
    # @since 0.1.0
    def unregister_with(event_class)
      managers.delete(event_class)
    end

    # @param manager [EvilEvents::Core::Events::Manager]
    # @return [Boolean]
    #
    # @since 0.1.0
    def include?(manager)
      managed_event?(manager.event_class) && manager_of_event(manager.event_class) == manager
    end

    # @param event_class [Class{EvilEvents::Core::Events::AbstractEvent}]
    # @return [Boolean]
    #
    # @since 0.1.0
    def managed_event?(event_class)
      managers.key?(event_class)
    end

    # @return [Hash]
    #
    # @since 0.2.0
    def managed_events_map
      managed_events.each_with_object({}) do |event, accumulator|
        accumulator[event.type] = event
      end
    end

    private

    # @return [Array<EvilEvents::Core::Events::AbstractEvent>]
    #
    # @since 0.1.0
    def managed_events
      managers.keys
    end

    # @return [Array<String>]
    #
    # @since 0.1.0
    def managed_event_types
      managed_events.map(&:type)
    end

    # @param event_type [String]
    # @return [Boolean]
    #
    # @since 0.1.0
    def managed_event_type?(event_type)
      managed_event_types.include?(event_type)
    end

    # @param manager [EvilEvents::Core::Events::Manager]
    # @return [Boolean]
    #
    # @since 0.1.0
    def potential_manager_duplicate?(manager)
      return false unless managed_event?(manager.event_class)
      manager_of_event(manager.event_class).event_type == manager.event_type
    end
  end
end
