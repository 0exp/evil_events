# frozen_string_literal: true

describe EvilEvents::Core::Broadcasting::Emitter::AdapterProxy, :stub_event_system do
  include_context 'event system'

  let(:sidekiq_adapter) { build_adapter_class.new }
  let(:rabbit_adapter)  { build_adapter_class.new }
  let(:redis_adapter)   { build_adapter_class.new }

  before do
    event_system.register_adapter(:sidekiq, sidekiq_adapter)
    event_system.register_adapter(:rabbit, rabbit_adapter)
    event_system.register_adapter(:redis, redis_adapter)
  end

  describe 'shared interface' do
    let(:rabbit_event)  { build_event_class { adapter :rabbit } }
    let(:sidekiq_event) { build_event_class { adapter :sidekiq } }

    context 'without explicit adapter identifier' do
      specify 'broadcasting works via event\'s pre-configured adapter' do
        adapter = described_class.new(rabbit_event)
        expect(rabbit_adapter).to receive(:call).with(rabbit_event).once
        adapter.broadcast!

        adapter = described_class.new(sidekiq_event)
        expect(sidekiq_adapter).to receive(:call).with(sidekiq_event).once
        adapter.broadcast!
      end
    end

    context 'with explicit adapter identifier' do
      specify 'broadcasting works via explicitly specified adapter' do
        adapter = described_class.new(rabbit_event, explicit_identifier: :redis)
        expect(redis_adapter).to receive(:call).with(rabbit_event).once
        expect(rabbit_adapter).not_to receive(:call)
        adapter.broadcast!

        adapter = described_class.new(sidekiq_event, explicit_identifier: :redis)
        expect(redis_adapter).to receive(:call).with(sidekiq_event).once
        expect(sidekiq_adapter).not_to receive(:call)
        adapter.broadcast!
      end

      specify 'fails when adapter with passed identifier isnt registered' do
        expect do
          described_class.new(sidekiq_event, explicit_identifier: gen_symb)
        end.to raise_error(Dry::Container::Error)
      end
    end
  end
end
