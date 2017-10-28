# frozen_string_literal: true

module EvilEvents::Core::Broadcasting
  # @api private
  # @since 0.1.0
  class Adapters
    include EvilEvents::Shared::DependencyContainer::Mixin

    # @return void
    #
    # @since 0.1.0
    def register_core_adapters!
      register(:memory_sync)  { MemorySync }
      register(:memory_async) { MemoryAsync }
    end
  end
end
