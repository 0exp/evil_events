# frozen_string_literal: true

class EvilEvents::Plugins
  # @api private
  # @since 0.5.0
  module MpackerEngine
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
        require 'msgpack'
      end

      # @return [void]
      #
      # @api private
      # @since 0.5.0
      def load_code!
        require_relative 'mpacker_engine/config'
        require_relative 'mpacker_engine/mpacker'
      end
    end
  end
end
