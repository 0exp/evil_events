# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers::Base
  # @api private
  # @since 0.4.0
  class EventSerializationState
    class << self
      # @param event [EvilEvents::Core::Event::AbstractEvent]
      # @return [EventSerializationState]
      #
      # @api private
      # @since 0.4.0
      def build_from_event(event)
        new(id: event.id, type: event.type, payload: event.payload, metadata: event.metadata)
      end

      # @option id [String,Integer,Object]
      # @option type [String]
      # @option payload [::Hash]
      # @option metadata [::Hash]
      # @return [EventSerializationState]
      #
      # @api private
      # @since 0.4.0
      def build_from_options(**options)
        new(**options)
      end
    end

    # @return [String, Integer, Object]
    #
    # @api private
    # @since 0.4.0
    attr_reader :id

    # @return [String]
    #
    # @api private
    # @since 0.4.0
    attr_reader :type

    # @return [::Hash]
    #
    # @api private
    # @since 0.4.0
    attr_reader :payload

    # @return [::Hash]
    #
    # @api private
    # @since 0.4.0
    attr_reader :metadata

    # @option id [String,Integer,Object]
    # @option type [String]
    # @option payload [::Hash]
    # @option metadata [::Hash]
    #
    # @api private
    # @since 0.4.0
    def initialize(id:, type:, payload:, metadata:)
      @id       = id
      @type     = type
      @payload  = payload
      @metadata = metadata
    end

    # @return [Boolean]
    #
    # @api private
    # @since 0.4.0
    def valid?
      return false unless type && payload && metadata
      return false unless payload.is_a?(::Hash)
      return false unless metadata.is_a?(::Hash)
      return false unless type.is_a?(String)
      true
    end
  end
end
