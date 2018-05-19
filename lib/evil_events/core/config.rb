# frozen_string_literal: true

module EvilEvents::Core
  # @api private
  # @since 0.1.0
  class Config < Qonfig::DataSet
    class << self
      # @api private
      # @since 0.1.0
      def build_stub
        new
      end
    end

    setting :serializers do
      setting :json do
        setting :engine, :native
      end

      setting :hashing do
        setting :engine, :native
      end

      setting :xml do
        setting :engine, :ox
      end

      setting :msgpack do
        setting :engine
      end
    end

    setting :adapter do
      setting :default, :memory_sync
    end

    setting :subscriber do
      setting :default_delegator, :call
    end

    setting :logger, EvilEvents::Shared::Logger.new(STDOUT)

    setting :notifier do
      setting :type, :sequential

      setting :sequential do
        # NOTE: place future settings here
      end

      setting :worker do
        setting :min_threads, 0
        setting :max_threads, 5
        setting :max_queue, 1000
        setting :fallback_policy, :main_thread
      end
    end
  end
end
