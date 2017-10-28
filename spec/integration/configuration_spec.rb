# frozen_string_literal: true

describe 'Configuration', :stub_config do
  specify 'configure common options' do
    null_logger = SpecSupport::NullLogger
    io_logger   = Logger.new(StringIO.new)

    # default settings
    expect(EvilEvents::Config.config.logger).to be_a(::Logger)
    expect(EvilEvents::Config.config.adapter.default).to eq(:memory_sync)
    expect(EvilEvents::Config.config.subscriber.default_delegator).to eq(:call)

    expect do
      # open configuration context
      EvilEvents::Config.configure do |config|
        # configure logger object
        config.logger = null_logger

        # configure adapter settings
        config.adapter.default = :memory_async

        # configure subscriber settings
        config.subscriber.default_delegator = :process_event
      end
    end.not_to raise_error

    expect(EvilEvents::Config.config.logger).to eq(null_logger)
    expect(EvilEvents::Config.config.adapter.default).to eq(:memory_async)
    expect(EvilEvents::Config.config.subscriber.default_delegator).to eq(:process_event)

    expect do
      # open configuration context
      EvilEvents::Config.config.configure do |config|
        # configure logger object
        config.logger = io_logger

        # configure adapter settings
        config.adapter.default = :memory_sync

        # configure subscriber settings
        config.subscriber.default_delegator = :invoke
      end
    end.not_to raise_error

    expect(EvilEvents::Config.config.logger).to eq(io_logger)
    expect(EvilEvents::Config.config.adapter.default).to eq(:memory_sync)
    expect(EvilEvents::Config.config.subscriber.default_delegator).to eq(:invoke)
  end

  specify 'registration of new adapter objects' do
    my_dumb_adapter   = double
    your_dumb_adapter = double

    # system pre-registered adapters
    expect(EvilEvents::Adapters[:memory_async]).to eq(
      EvilEvents::Core::Broadcasting::Adapters::MemoryAsync
    )
    expect(EvilEvents::Adapters[:memory_sync]).to eq(
      EvilEvents::Core::Broadcasting::Adapters::MemorySync
    )

    expect do
      EvilEvents::Adapters.register(:my_dumb_adapter, my_dumb_adapter)
      EvilEvents::Adapters.register(:your_dumb_adapter, your_dumb_adapter)
    end.not_to raise_error

    expect(EvilEvents::Adapters[:my_dumb_adapter]).to eq(my_dumb_adapter)
    expect(EvilEvents::Adapters[:your_dumb_adapter]).to eq(your_dumb_adapter)

    # already registered adapter cant be redefined
    expect { EvilEvents::Adapters.register(:my_dumb_adapter, double) }.to(
      raise_error(Dry::Container::Error)
    )

    # already registered adapter cant be redefined
    expect { EvilEvents::Adapters.register(:your_dumb_adapter, double) }.to(
      raise_error(Dry::Container::Error)
    )

    # system pre-registered adapter cant be redefined
    expect { EvilEvents::Adapters.register(:memory_async, double) }.to(
      raise_error(Dry::Container::Error)
    )

    # system pre-registered adapter cant be redefined
    expect { EvilEvents::Adapters.register(:memory_sync, double) }.to(
      raise_error(Dry::Container::Error)
    )

    # non-registerd adapter resolving should fail
    expect { EvilEvents::Adapters[:super_adapter] }.to(
      raise_error(Dry::Container::Error)
    )
  end
end
