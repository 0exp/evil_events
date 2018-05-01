# frozen_string_literal: true

module EvilEvents::Core::Events::EventExtensions
  # @api private
  # @since 0.1.0
  module Serializable
    # @return [Hash]
    #
    # @api private
    # @since 0.1.0
    def serialize_to_hash
      EvilEvents::Core::Bootstrap[:event_system].serialize_to_hash(self)
    end
    alias_method :dump_to_hash, :serialize_to_hash

    # @return [String]
    #
    # @api private
    # @since 0.1.0
    def serialize_to_json
      EvilEvents::Core::Bootstrap[:event_system].serialize_to_json(self)
    end
    alias_method :dump_to_json, :serialize_to_json

    # @return [String]
    #
    # @api private
    # @since 0.4.0
    def serialize_to_xml
      EvilEvents::Core::Bootstrap[:event_system].serialize_to_xml(self)
    end
    alias_method :dump_to_xml, :serialize_to_xml

    # @return [String]
    #
    # @api private
    # @since 0.4.0
    def serialize_to_msgpack
      EvilEvents::Core::Bootstrap[:event_system].serialize_to_msgpack(self)
    end
    alias_method :dump_to_msgpack, :serialize_to_msgpack
  end
end
