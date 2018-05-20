# frozen_string_literal: true

class EvilEvents::Plugins
  # @api private
  # @since 0.5.0
  module OxEngine
    class << self
      # @return [void]
      #
      # @api private
      # @since 0.5.0
      def load!
        load_dependencies!
        load_code!
      end

      private

      # @return [void]
      #
      # @api private
      # @since 0.5.0
      def load_dependencies!
        require 'ox'
      end

      # @return [void]
      #
      # @api private
      # @since 0.5.0
      def load_code!
        require_relative 'ox_engine/ox'
      end
    end
  end
end
