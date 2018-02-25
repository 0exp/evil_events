# frozen_string_literal: true

module EvilEvents::Core::Events::EventExtensions
  # @api private
  # @since 0.1.0
  module TypeAliasing
    class << self
      # @param base_class [Class]
      #
      # @since 0.1.0
      def included(base_class)
        base_class.extend(ClassMethods)
      end
    end

    # @return [String]
    #
    # @since 0.1.0
    def type
      self.class.type
    end

    module ClassMethods
      # @param type_alias [String, NilClass]
      # @raise [EvilEvents::IncopatibleEventTypeError]
      # @raise [EvilEvents::EventTypeNotDefinedError]
      # @raise [EvilEvents::EventTypeAlreadyDefinedError]
      # @return [String]
      #
      # @since 0.1.0
      def type(type_alias = nil)
        case
        when incompatible_type_alias_type?(type_alias)
          raise EvilEvents::IncopatibleEventTypeError
        when fetching_type_alias_when_type_alias_not_defined?(type_alias)
          raise EvilEvents::EventTypeNotDefinedError
        when providing_type_alias_when_type_alias_already_defined?(type_alias)
          raise EvilEvents::EventTypeAlreadyDefinedError
        when tries_to_define_type_alias_first_time?(type_alias)
          @type = type_alias
        end

        @type
      end

      private

      # @param type_alias [String, NilClass]
      # @return [Boolean]
      #
      # @since 0.1.0
      def incompatible_type_alias_type?(type_alias)
        !(type_alias.is_a?(NilClass) || type_alias.is_a?(String))
      end

      # @param type_alias [String, NilClass]
      # @return [Boolean]
      #
      # @since 0.1.0
      def fetching_type_alias_when_type_alias_not_defined?(type_alias)
        !instance_variable_defined?(:@type) && type_alias.nil?
      end

      # @param type_alias [String, NilClass]
      # @return [Boolean]
      #
      # @since 0.1.0
      def providing_type_alias_when_type_alias_already_defined?(type_alias)
        instance_variable_defined?(:@type) && type_alias
      end

      # @param type_alias [String, NilClass]
      # @return [Boolean]
      #
      # @since 0.1.0
      def tries_to_define_type_alias_first_time?(type_alias)
        !instance_variable_defined?(:@type) && type_alias
      end
    end
  end
end
