# frozen_string_literal: true

class EvilEvents::Core::System
  # @api private
  # @since 0.1.0
  module Mocking
    class << self
      # @param base_class [EvilEvents::Core::System]
      #
      # @since 0.1.0
      def included(base_class)
        base_class.extend(ClassMethods)
      end
    end

    # @since 0.1.0
    module ClassMethods
      # @return [EvilEvents::Core::System::Mock]
      #
      # @since 0.1.0
      def build_mock
        Mock.new
      end

      # @return [EvilEvents::Core::System]
      #
      # @since 0.1.0
      def build_stub
        new
      end
    end
  end
end
