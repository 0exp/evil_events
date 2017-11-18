# frozen_string_literal: true

module EvilEvents::Core::Events::EventExtensions::ClassSignature
  # @api private
  # @since 0.2.0
  class Equalizer
    # @rreturn [Signature]
    #
    # @since 0.2.0
    attr_reader :signature_a
    # @rreturn [Signature]
    #
    # @since 0.2.0
    attr_reader :signature_b

    # @param signature_a [Signature]
    # @param signature_b [Signature]
    #
    # @since 0.2.0
    def initialize(signature_a, signature_b)
      @signature_a = signature_a
      @signature_b = signature_b
    end

    # @return [Boolean]
    #
    # @since 0.2.0
    def equal_payload?
      signature_a.payload_stamp == signature_b.payload_stamp
    end

    # @return [Boolean]
    #
    # @since 0.2.0
    def equal_metadata?
      signature_a.metadata_stamp == signature_b.metadata_stamp
    end

    # @return [Boolean]
    #
    # @since 0.2.0
    def equal_delegator?
      signature_a.delegator_stamp == signature_b.delegator_stamp
    end

    # @return [Boolean]
    #
    # @since 0.2.0
    def equal_adapter?
      signature_a.adapter_stamp == signature_b.adapter_stamp
    end

    # @return [Boolean]
    #
    # @since 0.2.0
    def equal_type_alias?
      signature_a.type_alias_stamp == signature_b.type_alias_stamp
    end

    # @return [Boolean]
    #
    # @since 0.2.0
    def equal_class?
      signature_a.class_stamp == signature_b.class_stamp
    end

    # @option strict [Boolean]
    # @return [Boolean]
    #
    # @since 0.2.0
    def similar_signatures?
      # rubocop:disable Layout/MultilineOperationIndentation
      equal_type_alias? &&
      equal_class?      &&
      equal_payload?    &&
      equal_metadata?   &&
      equal_delegator?  &&
      equal_adapter?
      # rubocop:enable Layout/MultilineOperationIndentation
    end
  end
end
