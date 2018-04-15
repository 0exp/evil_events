# frozen_string_literal: true

module EvilEvents::Core::Events::EventExtensions
  # @api private
  # @since 0.1.0
  module Serializable
    # @return [Hash]
    #
    # @since 0.1.0
    def serialize_to_hash
      EvilEvents::Core::Events::Serializers[:hash].serialize(self)
    end
    alias_method :dump_to_hash, :serialize_to_hash

    # @return [String]
    #
    # @since 0.1.0
    def serialize_to_json
      EvilEvents::Core::Events::Serializers[:json].serialize(self)
    end
    alias_method :dump_to_json, :serialize_to_json

    # @return [String]
    #
    # @since 0.4.0
    def serialize_to_xml
      EvilEvents::Core::Events::Serializers[:xml].serialize(self)
    end
    alias_method :dump_to_xml, :serialize_to_xml
  end
end
