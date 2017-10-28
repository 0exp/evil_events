# frozen_string_literal: true

module EvilEvents::Shared
  class CombinedContext
    # @example
    #  require 'securerandom'
    #
    #  class Event
    #    extend EvilEvents::Shared::CombinedContext::Mixin
    #
    #    class << self
    #      def type(type = nil)
    #        @type = type if type
    #        @type
    #       end
    #    end
    #  end
    #
    #  def get_uuid
    #    SecureRandom.uuid
    #  end
    #
    #  MyEvent = Event.evaluate do
    #    type get_uuid # Event.type + binding#get_uuid => works good :)
    #  end
    #
    # @see EvilEvents::Shared::CombinedContext
    #
    # @api public
    # @since 0.1.0
    module Mixin
      # @param clojure [Proc]
      # @return [Object] Clojure evaluation result
      #
      # @see EvilEvents::Shared::CombinedContext#evaluate
      #
      # @since 0.1.0
      def evaluate(&clojure)
        CombinedContext.new(self, clojure).evaluate
      end
    end
  end
end
