# frozen_string_literal: true

require 'dry-configurable'
require 'dry-container'
require 'dry-struct'
require 'dry-types'
require 'concurrent/array'
require 'concurrent/map'
require 'symbiont'
require 'securerandom'
require 'forwardable'
require 'logger'
require 'json'
require 'ox'

# @api public
# @since 0.1.0
module EvilEvents
  require_relative 'evil_events/version'
  require_relative 'evil_events/shared'
  require_relative 'evil_events/types'
  require_relative 'evil_events/error'
  require_relative 'evil_events/core'
  require_relative 'evil_events/config'
  require_relative 'evil_events/event'
  require_relative 'evil_events/serializer'
  require_relative 'evil_events/emitter'
  require_relative 'evil_events/subscriber_mixin'
  require_relative 'evil_events/dispatcher_mixin'
  require_relative 'evil_events/application'
  require_relative 'evil_events/plugins'
end
