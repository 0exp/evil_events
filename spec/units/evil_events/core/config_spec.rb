# frozen_string_literal: true

describe EvilEvents::Core::Config do
  let(:config) { described_class.new }

  specify 'delegation interface works correctly with configuration interface' do
    # main delegated methods:
    #   - setting
    #   - configure

    expect(config.methods).not_to include(:setting, :configure)

    expect(config).to respond_to(:setting)
    expect(config).to respond_to(:configure)

    expect { config.method(:setting) }.not_to raise_error
    expect { config.method(:configure) }.not_to raise_error
  end

  specify 'default configs' do
    expect(config.adapter.default).to eq(:memory_sync)
    expect(config.subscriber.default_delegator).to eq(:call)
    expect(config.logger).to be_a(EvilEvents::Shared::Logger)
  end

  specify 'all meaningful options are configurable' do
    logger = double

    config.configure do |c|
      c.adapter.default = :sidekiq
      c.subscriber.default_delegator = :process_event
      c.logger = logger
    end

    expect(config.adapter.default).to eq(:sidekiq)
    expect(config.subscriber.default_delegator).to eq(:process_event)
    expect(config.logger).to eq(logger)

    config.configure do |c|
      c.adapter.default = :redis
      c.subscriber.default_delegator = :invoke
      c.logger = SpecSupport::NullLogger
    end

    expect(config.adapter.default).to eq(:redis)
    expect(config.subscriber.default_delegator).to eq(:invoke)
    expect(config.logger).to eq(SpecSupport::NullLogger)
  end
end
