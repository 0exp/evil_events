# Changelog
All notable changes to this project will be documented in this file.

## [Unreleased]
### Added
- Support for Ruby 2.5.0
- Introduce Event Emition Hooks API. Supported hooks (are decalred in an event class):
  - `before_emit -> (event) {} # proc/lambda` - invoked once before an event emition process;
  - `after_emit -> (event) {} # proc/lambda` - invoked once after an event emition process;
  - `on_error -> (event, error) {} # proc/lambda` - invoked on each raised error due to emition process
    (usually these errors are raised by subscribers and their's event processing methods)

## [0.2.0] - 2017-11-19
### Added
- Support for custom coercive types:
  - New utility for custom coercive types: `EvilEvents::Shared::TypeConverter`
  - `AbstractEvent` supports new coercive types (metadata and payload are supported)
  - Configuration point for coercive types: `EvilEvents::Config.setup_types { |types| ... }`
- Configuration point for adapters: `EvilEvents::Config.setup_adapters { |adapters| ... }`
- General class for internal errors: now all internal `*Error` classes inherits from `EvilEvents::Core::Error`
- Access to the list of registered event classes via `EvilEvents::Application.registered_events`
- Plugin ecosystem: see `EvilEvents::Plugins` (simple API example: `EvilEvents::Plugins.load!(:rails)`)
- Comparable event class signature object `<EventClass>.signature` with data about:
  -  class name
  -  class creation strategy
  -  adapter info (name and object)
  -  default delegator method name
  -  metadata attributes schema
  -  payload attributes schema
  -  string type alias
- Event subscriptions via event type alias pattern (Regexp) and conditional proc (Proc)
- The ability to subscribe to the list of events (via list of event type attributes)

### Changed
- Renamed config opts aggregator: `EvilEvents::Config.config` => `EvilEvents::Config.options`
- Moved adapters config object: `EvilEvents::Adapters` => `EvilEvents::Config::Adapters`

### Fixed
- Fixed a bug when an event created by an exceptional block still remains in the internal event registry

## [0.1.1] - 2017-10-29
### Added
- Serialization of event ids: support for using :id key in JSON/Hash serialization/deserialization.
