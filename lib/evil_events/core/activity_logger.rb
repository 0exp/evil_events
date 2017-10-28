# frozen_string_literal: true

module EvilEvents::Core
  # @api private
  # @since 0.1.0
  class ActivityLogger
    class << self
      # @param activity [String, NilClass]
      # @param message [String, NilClass]
      # @return void
      #
      # @since 0.1.0
      def log(activity: nil, message: nil)
        progname = "[EvilEvents:#{activity}]"
        logger.add(logger.level, message, progname)
      end

      private

      # @return [Logger]
      #
      # @since 0.1.0
      def logger
        EvilEvents::Core::Bootstrap[:config].logger
      end
    end
  end
end
