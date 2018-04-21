# Changelog
All notable changes to this project will be documented in this file.

## [Unreleased]
### Added
- **Routing Key Based Event Types**. A new way of subscribing to events and approach to event naming: routing-key-based event naming;
  - Event names must be named in the routing-key style;
  - New method for subscription: `EvilEvents::SubscriberMixin#subscribe_to_scope(*event_scopes, delegator: nil)`;
  - Event subscription follows this pattern:
    - `*` - manadtory presence of the event scope (this pattern requires an event scope presence);
    - `#` - any count of event scopes (zero or more) (this pattern doesnt require an event scope presence);
    - `.` - event scope splitter;
    - `other symbols` - chars for event scope names;
  - Example (our events: `user`, `user.created`, `user.created.tomorrow`, `deposit`, `deposit.created`, `created`, `created.today`):
    - `user.#` - all event types starting with `user` (`user`, `user.created`, `user.created.tomorrow`);
    - `user.*` - all events with only TWO parts. `user` part is required (`user.created`);
    - `*.created.#` => `user.created.tomorrow`, `user.created`, `deposit.created`;
    - `#.created.*` => `user.created.tomorrow`, `user.created`, `created`, `created.today`, `deposit.created`;
    - `#` => all events;
    - `*` => events with only one part in name: `user`, `deposit`, `created`;
    - and etc;
- Support for Ruby `2.2.10`, `2.3.7`, `2.4.4`, `2.5.1`;
- Ability to broadcast events via any registered adapter by explicitly passed `:adapter` attribute in emition methods:
  - `EvilEvents::Emitter.emit('your_event_type', adapter: :your_adapter_identifier, **event_attrs)`;
  - `YourEventClass.emit!(adapter: :your_adapter_identifier, **event_attrs)`;
  - `your_event.emit!(adapter: :your_adapter_identifier)`;
- Added XML event serialization format (no more JRuby at this moment **:(**):
  - `EvilEvents::Serializer.load_from_xml(event)` - returns an event object;
  - `your_event.serialize_to_xml` - returns xml string;
  - `your_event.dump_to_xml` - returns xml string (`serialize_to_xml` alias);
- Added an ability to check an event object similarity:
  - `your_event.similar_to?(another_event)` - `returns` true if `another_event` has equal id/type/metadata/paylaod
    attributes (and interface) - otherwise returns `false`.

### Changed
- Removed `EvilEvents::CombinedContext` class and submodules => `Symbiont` is used instead (gem `symbiont-ruby`);
- Added specific serialization error classes (inherited from `EvilEvents::SerializationError`:
  - `EvilEvents::HashSerializationError`;
  - `EvilEvents::HashDeserializationError`;
  - `EvilEvents::JSONSerializationError`;
  - `EvilEvents::JSONSerializationError`;
  - `EvilEvents::XMLSerializationError`;
  - `EvilEvents::XMLSerializationError`.

## [0.3.1] - 2018-03-01
### Fixed
- A problem with Forwardable constant resolution when it cant be resolved due to dynamic definition in error classes (NameError fix).

## [0.3.0] - 2018-02-25
### Added
- Support for Ruby 2.5.0
- Introduce Event Emition Hooks API. Supported hooks (are decalred in an event class):
  - `before_emit -> (event) {} # proc/lambda` - invoked once before an event emition process;
  - `after_emit -> (event) {} # proc/lambda` - invoked once after an event emition process;
  - `on_error -> (event, error) {} # proc/lambda` - invoked on each raised error due to emition process
    (usually these errors are raised by subscribers and their's event processing methods)
- Added `AbstractEvent.emit!(**event_attributes)` method to provide an ability to emit events via event class constant.

### Changed
- New more convenient exception hierarchy: now all exceptions live under `EvilEvents` namespace.
- Full refactoring of the event notification abstraction. New types of notifying processes:
  - `sequential` (single-threaded): ordered notification logic, subscribers are notified one after the other;
  - `worker` (multi-threaded): unordered notification logic, each subscriber is notified in own thread (depending on the settings);
  - Process type should be globally pre-configured before application startup (new configuration options for each type of process);
  - Notifier can be restarted via `EvilEvents::Application.restart_event_notifier` (it would be convenient to have an ability to reload/restart notifier object in development mode interactively).

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
