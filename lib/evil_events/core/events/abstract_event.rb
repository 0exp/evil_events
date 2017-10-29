# frozen_string_literal: true

module EvilEvents::Core::Events
  # @abstract
  # @api private
  # @since 0.1.0
  class AbstractEvent
    # @since 0.1.0
    include EventExtensions::TypeAliasing
    # @since 0.1.0
    include EventExtensions::Payloadable
    # @since 0.1.0
    include EventExtensions::Manageable
    # @since 0.1.0
    include EventExtensions::Observable
    # @since 0.1.0
    include EventExtensions::AdapterCustomizable
    # @since 0.1.0
    include EventExtensions::Serializable
    # @since 0.1.0
    include EventExtensions::Emittable
    # @since 0.1.0
    include EventExtensions::MetadataExtendable
    # @since 0.1.0
    extend EvilEvents::Shared::CombinedContext::Mixin

    # @return [String]
    #
    # @api public
    # @since 0.1.0
    attr_reader :id

    # @option payload [Hash]
    # @option metadata [Hash]
    #
    # @since 0.1.0
    def initialize(id: nil, payload: {}, metadata: {})
      @id       = id || EvilEvents::Shared::Crypto.uuid
      @payload  = build_payload(**payload)
      @metadata = build_metadata(**metadata)
    end

    # @return [Hash]
    #
    # @api public
    # @since 0.1.0
    def payload
      @payload.to_h
    end

    # @return [Hash]
    #
    # @api public
    # @since 0.1.0
    def metadata
      @metadata.to_h
    end
  end
end
