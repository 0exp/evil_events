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
    include EventExtensions::Serializable
    # @since 0.1.0
    include EventExtensions::MetadataExtendable
    # @sicne 0.2.0
    include EventExtensions::ClassSignature
    # @since 0.3.0
    include EventExtensions::Hookable
    # @since 0.4.0
    include EventExtensions::Dispatchable
    # @since 0.4.0
    extend Symbiont::Context

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
