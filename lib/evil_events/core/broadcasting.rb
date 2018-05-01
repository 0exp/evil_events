# frozen_string_literal: true

module EvilEvents::Core
  # @api private
  # @since 0.1.0
  module Broadcasting
    require_relative 'broadcasting/dispatcher'
    require_relative 'broadcasting/dispatcher/mixin'
    require_relative 'broadcasting/adapters'
    require_relative 'broadcasting/adapters/memory_sync'
    require_relative 'broadcasting/adapters/memory_async'
    require_relative 'broadcasting/emitter'
    require_relative 'broadcasting/emitter/adapter_proxy'
  end
end
