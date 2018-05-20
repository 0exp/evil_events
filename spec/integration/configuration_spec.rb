# frozen_string_literal: true

describe 'Configuration', :stub_event_system do
  specify 'configure common options' do
    null_logger = SpecSupport::NullLogger
    io_logger   = Logger.new(StringIO.new)

    # default settings
    expect(EvilEvents::Config.options.logger).to be_a(::Logger)
    expect(EvilEvents::Config.options.adapter.default).to eq(:memory_sync)
    expect(EvilEvents::Config.options.subscriber.default_delegator).to eq(:call)

    # open configuration context
    EvilEvents::Config.configure do |config|
      # configure logger object
      config.logger = null_logger

      # configure adapter settings
      config.adapter.default = :memory_async

      # configure subscriber settings
      config.subscriber.default_delegator = :process_event
    end

    expect(EvilEvents::Config.options.logger).to eq(null_logger)
    expect(EvilEvents::Config.options.adapter.default).to eq(:memory_async)
    expect(EvilEvents::Config.options.subscriber.default_delegator).to eq(:process_event)

    # open configuration context
    EvilEvents::Config.configure do |config|
      # configure logger object
      config.logger = io_logger

      # configure adapter settings
      config.adapter.default = :memory_sync

      # configure subscriber settings
      config.subscriber.default_delegator = :invoke
    end

    expect(EvilEvents::Config.options.logger).to eq(io_logger)
    expect(EvilEvents::Config.options.adapter.default).to eq(:memory_sync)
    expect(EvilEvents::Config.options.subscriber.default_delegator).to eq(:invoke)
  end

  specify 'registration of new adapters' do
    sidekiq_adapter = double
    redis_adapter   = double

    # register adapters
    EvilEvents::Config.setup_adapters do |adapters|
      adapters.register(:sidekiq, sidekiq_adapter)
      adapters.register(:redis,   redis_adapter)
    end

    # registered adapters
    expect(EvilEvents::Config::Adapters[:sidekiq]).to eq(sidekiq_adapter)
    expect(EvilEvents::Config::Adapters[:redis]).to eq(redis_adapter)

    # system pre-registered adapters
    expect(EvilEvents::Config::Adapters[:memory_async]).to eq(
      EvilEvents::Core::Broadcasting::Adapters::MemoryAsync
    )
    expect(EvilEvents::Config::Adapters[:memory_sync]).to eq(
      EvilEvents::Core::Broadcasting::Adapters::MemorySync
    )

    # already registered adapter cant be redefined
    expect { EvilEvents::Config::Adapters.register(:sidekiq, double) }.to(
      raise_error(Dry::Container::Error)
    )

    # already registered adapter cant be redefined
    expect { EvilEvents::Config::Adapters.register(:redis, double) }.to(
      raise_error(Dry::Container::Error)
    )

    # system pre-registered adapter cant be redefined
    expect { EvilEvents::Config::Adapters.register(:memory_async, double) }.to(
      raise_error(Dry::Container::Error)
    )

    # system pre-registered adapter cant be redefined
    expect { EvilEvents::Config::Adapters.register(:memory_sync, double) }.to(
      raise_error(Dry::Container::Error)
    )

    # non-registerd adapter resolving should fail
    expect { EvilEvents::Config::Adapters[:super_adapter] }.to raise_error(Dry::Container::Error)
  end

  specify 'registration of coercible event attribute types' do
    # try to use coercible types
    expect do
      EvilEvents::Event.define('user_registered') do
        payload :user_id, :sequence, default: -1
        payload :comment, :text,     default: ''
        payload :sha256,  EvilEvents::Types::Strict::String

        metadata :timestamp, :time, default: Time.now
        metadata :server_id, :uuid
        metadata :ref_id,    EvilEvents::Types::Strict::Integer
      end
    end.to raise_error(Dry::Container::Error)

    # register missing coercible types
    EvilEvents::Config.setup_types do |types|
      types.define_converter(:sequence, &:to_i)

      types.define_converter(:time) do |value|
        Time.parse(value)
      end

      types.define_converter(:uuid) do
        SecureRandom.uuid
      end

      types.define_converter(:text) do |value|
        value.to_s.strip!
      end
    end

    # try to use coercible types again
    expect do
      EvilEvents::Event.define('user_registered') do
        payload :user_id, :sequence, default: -1
        payload :comment, :text,     default: ''
        payload :sha256,  EvilEvents::Types::Strict::String

        metadata :timestamp, :time, default: Time.now
        metadata :server_id, :uuid
        metadata :ref_id,    EvilEvents::Types::Strict::Integer
      end
    end.not_to raise_error
  end

  specify 'event notifier configuration' do
    # sequential (single threaded) notifier is a default option
    expect(EvilEvents::Config.options.notifier.type).to eq(:sequential)

    # use worker (multithreaded) notifier
    EvilEvents::Config.configure do |config|
      config.notifier.type = :worker
    end

    expect(EvilEvents::Config.options.notifier.type).to eq(:worker)

    # default worker notifier settings
    EvilEvents::Config.options.notifier.worker.tap do |options|
      expect(options.min_threads).to     eq(0)
      expect(options.max_threads).to     eq(5)
      expect(options.max_queue).to       eq(1000)
      expect(options.fallback_policy).to eq(:main_thread)
    end

    # configure worker notifier
    EvilEvents::Config.configure do |config|
      config.notifier.worker.min_threads     = 1
      config.notifier.worker.max_threads     = 15
      config.notifier.worker.max_queue       = 20
      config.notifier.worker.fallback_policy = :exception
    end

    EvilEvents::Config.options.notifier.worker.tap do |options|
      expect(options.min_threads).to     eq(1)
      expect(options.max_threads).to     eq(15)
      expect(options.max_queue).to       eq(20)
      expect(options.fallback_policy).to eq(:exception)
    end
  end
end
