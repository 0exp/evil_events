# Changelog
All notable changes to this project will be documented in this file.

## [Unreleased]
### Added
- Added Oj serialization engine for JSON format;
- Moved to plugins:
  - Ox serialization engine:
    - requires `gem ox ~> 2.9.2`;
    - configuration:
      - `EvilEvents::Plugins.load! :ox_engine`
      - `EvilEvents::Config.configure { |c| c.serializers.xml.engine = :ox }`
  - Oj serialization engine:
    - requires `gem oj ~> 3.6.0`
    - configuration:
      - `EvilEvents::Plugins.load! :oj_engine`
      - `EvilEvents::Config.configure { |c| c.serializers.json.engine = :oj }`
  - Mpacker serialization engine (uses gem `msgpack` with native dependencies)
    - requires `gem msgpack ~> 1.2.4`
    - configuration:
      - `EvilEvents::Plugins.load! :mpacker_engine`
      - `EvilEvents::Config.configure { |c| c.serializers.msgpack.engine = :mpacker }`
  - No more `dry-configurable` dependency => gem `qonfig` is used instead;
  - JRuby is BACK! 💣

## [0.4.0] - 2018-05-02
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
  - `EvilEvents::Serializer.load_from_xml(xml)` - returns an event object;
  - `your_event.serialize_to_xml` - returns xml string;
  - `your_event.dump_to_xml` - returns xml string (`serialize_to_xml` alias);
- Added MessagePack event serialization format (no more JRuby at this moment **:(**):
  - `EvilEvents::Serializer.load_from_msgpack(message)` - returns an event object;
  - `your_event.serialize_to_msgpack` - returns messagepack string;
  - `your_event.dump_to_msgpack` - returns messagepack string (`serialize_to_msgpack` alias);
- Added an ability to check an event object similarity:
  - `your_event.similar_to?(another_event)` - `returns` true if `another_event` has equal id/type/metadata/paylaod
    attributes (and interface) - otherwise returns `false`.

### Changed
- Removed `EvilEvents::Shared::Configurable` => `EvilEvents::Shared::AnyConfig` is used instead (smart dry-configurable wrapper);
- Removed `EvilEvents::Shared::CombinedContext` class and submodules => `Symbiont` is used instead (gem `symbiont-ruby`);
- Refactored event serialization abstraction:
  - Each event serializer represents a complex logic now and is constructed by a set of objects:
    - engines - low-level data-transformers, works with event serialization state (event data mapper);
    - packer - responsible for serialization via corresponding engine  (works with events and event serialization state);
    - unpacker - responsible for deserialization logic via corresponding engine (works with low-level data and event serialization state);
    - serializers container;
    - config - configuration point of the each serializer;
    - event serialization state - event data mapper (id, type, payload, metadata), engines works with this state;
  - Supported engines:
    - Hash (`:native`) - based on ::Hash class;
    - JSON (`:native`) - based on ::JSON class;
    - MessagePack (`:mpacker`) - based on MessagePack gem;
    - XML (`:ox`) - based on Ox gem;
  - Added configuration points for the each type of serializer:
    - `EvilEvents::Config.options.serializers` - root
    - `EvilEvents::Config.options.serializers.json.engine` - `:native` by default;
    - `EvilEvents::Config.options.serializers.hashing.enigne` - `:native` by default;
    - `EvilEvents::Config.options.serializers.xml.engine` - `:native` by default;
    - `EvilEvents::Config.options.serializers.msgpack.engine` - `:mpacker` by default;
    - `EvilEvents::Config.options.serializers.msgpack.mpacker.configurator` - `->(engine) {}` by default;
- Added specific serialization error classes (inherited from `EvilEvents::SerializationError`/`EvilEvents::DeserializationError` respectively):
  - `EvilEvents::SerializersError`
  - `EvilEvents::SerializationError`
  - `EvilEvents::JSONSerializationError`
  - `EvilEvents::XMLSerializationError`
  - `EvilEvents::HashSerializationError`
  - `EvilEvents::MessagePackSerializationError`
  - `EvilEvents::DeserializationError`
  - `EvilEvents::JSONDeserializationError`
  - `EvilEvents::XMLDeserializationError`
  - `EvilEvents::HashDeserializationError`
  - `EvilEvents::MessagePackDeserializationError`
  - `EvilEvents::SerializationEngineError`
  - `EvilEvents::UnrecognizedSerializationEngineError`

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
