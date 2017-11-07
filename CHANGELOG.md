# Changelog
All notable changes to this project will be documented in this file.

## [Unreleased]

### [Added]
- Support for custom coercive types:
  - New utility for generating the custom coercive types: `EvilEvents::Shared::TypeConverter`
  - `AbstractEvent` supports new coercive types (metadata and payload are supported)
  - Configuration point for coercive types: `EvilEvents::Config.setup_types { |types| ... }`
  - Configuration point for adapters: `EvilEvents::Config.setup_adapters { |adapters| ... }`
- General class for internal errors: now all internal `*Error` classes inherits from `EvilEvents::Core::Error`

### [Changed]
- Renamed config opts aggregator: `EvilEvents::Config.config` => `EvilEvents::Config.options`
- Move adapters config object to the appropriate place: `EvilEvents::Adapters` => `EvilEvents::Config::Adapters`

### [Fixed]
- Fixed a bug when an event created by an exceptional block still remains in the internal event registry

## [0.1.1] - 2017-10-29
### [Added]
- Serialization of event ids: support for using :id key in JSON/Hash serialization/deserialization.
