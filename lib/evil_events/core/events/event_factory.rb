# frozen_string_literal: true

module EvilEvents::Core::Events
  # @api private
  # @since 0.1.1
  module EventFactory
    # @since 0.1.1
    UNDEFINED_EVENT_ID         = 'unknown'
    CLASS_INHERITANCE_STRATEGY = :class_inheritance
    PROC_EVAL_STRATEGY         = :proc_eval

    module_function

    # @param event_type [String]
    # @raise [EvilEvents::Core::Events::ManagerRegistry::AlreadyManagedEventClassError]
    # @return [Class{EvilEvents::Core::Events::AbstractEvent}]
    #
    # @since 0.1.1
    def create_abstract_class(event_type)
      Class.new(AbstractEvent).tap do |klass|
        klass.type(event_type)
        klass.__creation_strategy__ = CLASS_INHERITANCE_STRATEGY

        class << klass
          def inherited(child_class)
            child_class.type(type)
            child_class.__creation_strategy__ = CLASS_INHERITANCE_STRATEGY
            child_class.manage!
          rescue EvilEvents::AlreadyManagedEventClassError
            EvilEvents::Core::Bootstrap[:event_system].unregister_event_class(child_class)
            raise
          end
        end
      end
    end

    # @param event_type [String]
    # @param event_class_definitions [Proc]
    # @yield [AbstractEvent]
    # @raise [EvilEvents::Core::Events::ManagerRegistry::AlreadyManagedEventClassError]
    # @return [Class{EvilEvents::Core::Events::AbstractEvent}]
    #
    # @since 0.1.1
    def create_class(event_type, &event_class_definitions)
      Class.new(AbstractEvent).tap do |klass|
        begin # rubocop:disable Style/RedundantBegin
          klass.__creation_strategy__ = PROC_EVAL_STRATEGY
          klass.type(event_type)
          klass.manage!
          klass.evaluate(&event_class_definitions) if block_given?
        rescue StandardError
          EvilEvents::Core::Bootstrap[:event_system].unregister_event_class(klass)
          raise
        end
      end
    end

    # @param event_class [Class{EvilEvents::Core::Events::AbstractEvent}]
    # @option id [String, Object]
    # @option payload [Hash]
    # @option metadata [Hash]
    # @return [EvilEvents::Core::Events::AbstractEvent]
    #
    # @api private
    # @since 0.1.1
    def restore_instance(event_class, id: UNDEFINED_EVENT_ID, payload: {}, metadata: {})
      event_class.new(id: id || UNDEFINED_EVENT_ID, payload: payload, metadata: metadata)
    end
  end
end
