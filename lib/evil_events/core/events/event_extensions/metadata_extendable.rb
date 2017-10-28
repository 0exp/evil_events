# frozen_string_literal: true

module EvilEvents::Core::Events::EventExtensions
  # @api private
  # @since 0.1.0
  module MetadataExtendable
    class << self
      # @param base_class [Class]
      #
      # @since 0.1.0
      def included(base_class)
        base_class.extend(ClassMethods)
      end
    end

    private

    # @return [Class{AbstractMetadata}]
    #
    # @since 0.1.0
    def build_metadata(**metadata_attributes)
      self.class.const_get(:Metadata).new(**metadata_attributes)
    end

    # @since 0.1.0
    module ClassMethods
      # @param child_class [Class]
      #
      # @since 0.1.0
      def inherited(child_class)
        child_class.const_set(:Metadata, Class.new(AbstractMetadata))
        super
      end

      # @param key [Symbol]
      # @param type [EvilEvents::Shared::Types::Any]
      # @return void
      #
      # @since 0.1.0
      def metadata(key, type = EvilEvents::Types::Any)
        const_get(:Metadata).attribute(key, type)
      end

      # @return [Array<Symbol>]
      #
      # @since 0.1.0
      def metadata_fields
        const_get(:Metadata).attribute_names
      end
    end
  end
end
