# frozen_string_literal: true

module EvilEvents::Core::Broadcasting
  class Adapters
    # @api public
    # @since 0.1.0
    module MemorySync
      class << self
        # @since 0.1.0
        include Dispatcher::Mixin

        # @param event [EvilEvents::Core::Events::AbstractEvent]
        # @return void
        #
        # @since 0.1.0
        def call(event)
          dispatch(event)
        end
      end
    end
  end
end
