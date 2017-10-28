# frozen_string_literal: true

module EvilEvents::Core::Events
  # @api private
  # @since 0.1.0
  module EventClassFactory
    class << self
      # @param event_type [String]
      # @raise [EvilEvents::Core::Events::ManagerRegistry::AlreadyManagedEventClassError]
      # @return [Class{EvilEvents::Core::Events::AbstractEvent}]
      #
      # @since 0.1.0
      def create_abstract(event_type)
        Class.new(AbstractEvent).tap do |klass|
          klass.type(event_type)

          class << klass
            def inherited(child_class)
              child_class.type(type)
              child_class.manage!
            rescue EvilEvents::Core::Events::ManagerRegistry::AlreadyManagedEventClassError
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
      # @since 0.1.0
      def create(event_type, &event_class_definitions)
        Class.new(AbstractEvent).tap do |klass|
          begin
            klass.type(event_type)
            klass.manage!
            klass.evaluate(&event_class_definitions) if block_given?
          rescue EvilEvents::Core::Events::ManagerRegistry::AlreadyManagedEventClassError
            EvilEvents::Core::Bootstrap[:event_system].unregister_event_class(klass)
            raise
          end
        end
      end
    end
  end
end
