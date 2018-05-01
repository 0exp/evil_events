# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers::Base
  # @api private
  # @since 0.4.0
  class AbstractEngine
    # @param config [GenericConfig]
    #
    # @api private
    # @since 0.4.0
    def initialize(config); end

    # @param data [EventSerializationState]
    # @return [Object]
    #
    # @api private
    # @since 0.4.0
    def dump(serialization_state); end

    # @param data [Object]
    # @return [EventSerializationState]
    #
    # @api private
    # @since 0.4.0
    def load(data); end

    private

    # @option id [String,Integer,Object]
    # @option type [String]
    # @option payload [::Hash]
    # @option metadata [::Hash]
    #
    # @return [EventSerializationState]
    #
    # @api private
    # @since 0.4.0
    def restore_serialization_state(id:, type:, payload:, metadata:)
      EventSerializationState.build_from_options(
        id:       id,
        type:     type,
        payload:  payload,
        metadata: metadata
      )
    end
  end
end
