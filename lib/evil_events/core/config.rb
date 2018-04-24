# frozen_string_literal: true

module EvilEvents::Core
  # @api private
  # @since 0.1.0
  class Config < EvilEvents::Shared::AnyConfig
    class << self
      # @api private
      # @since 0.1.0
      def build_stub
        new
      end
    end

    # rubocop:disable Metrics/BlockLength
    configure do
      setting :serializers, reader: true do
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
          setting :engine, :mpacker

          setting :mpacker do
            setting :configurator, ->(engine) {}
          end
        end
      end

      setting :adapter, reader: true do
        setting :default, :memory_sync
      end

      setting :subscriber, reader: true do
        setting :default_delegator, :call
      end

      setting :logger, EvilEvents::Shared::Logger.new(STDOUT), reader: true

      setting :notifier, reader: true do
        setting :type, :sequential

        setting :sequential, reader: true do
          # NOTE: place future settings here
        end

        setting :worker, reader: true do
          setting :min_threads, 0
          setting :max_threads, 5
          setting :max_queue, 1000
          setting :fallback_policy, :main_thread
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
