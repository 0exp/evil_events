# frozen_string_literal: true

module EvilEvents::Core::Events
  # @api private
  # @since 0.1.0
  module ManagerFactory
    # @since 0.1.0
    ManagerFactoryError = Class.new(EvilEvents::Core::Error)
    # @since 0.1.0
    IncorrectEventClassError = Class.new(ManagerFactoryError)

    class << self
      # @param event_class [Class{EvilEvents::Core::Events::AbstractEvent}]
      # @raise [IncorrectEventClassError]
      # @return [EvilEvents::Core::Events::Manager]
      #
      # @since 0.1.0
      def create(event_class)
        unless event_class.is_a?(Class) && event_class < EvilEvents::Core::Events::AbstractEvent
          raise IncorrectEventClassError
        end

        Manager.new(event_class)
      end
    end
  end
end
