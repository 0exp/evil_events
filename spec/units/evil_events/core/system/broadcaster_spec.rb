# frozen_string_literal: true

describe EvilEvents::Core::System::Broadcaster, :stub_event_system, :null_logger do
  describe 'instance state' do
    let(:broadcaster) { described_class.new }

    describe 'attributes' do
      describe '#event_emitter' do
        specify 'event emitter instance with initial state' do
          expect(broadcaster.event_emitter).to be_a(EvilEvents::Core::Broadcasting::Emitter)
        end
      end

      describe '#event_notifier' do
        context 'configured as single-threaded' do
          before do
            EvilEvents::Core::Bootstrap[:config].configure do |config|
              config.notifier.type = :sequential
            end
          end

          specify do
            expect(broadcaster.event_notifier).to be_a(EvilEvents::Core::Events::Notifier::Proxy)

            expect(broadcaster.event_notifier.notifier).to be_a(
              EvilEvents::Core::Events::Notifier::Sequential
            )
          end
        end

        context 'configured as multi-threaded' do
          before do
            EvilEvents::Core::Bootstrap[:config].configure do |config|
              config.notifier.type = :worker
            end
          end

          specify do
            expect(broadcaster.event_notifier).to be_a(EvilEvents::Core::Events::Notifier::Proxy)

            expect(broadcaster.event_notifier.notifier).to be_a(
              EvilEvents::Core::Events::Notifier::Worker
            )
          end
        end
      end

      describe '#adapters_container' do
        specify 'adapters container instance with pre-registered core adapters' do
          expect(broadcaster.adapters_container).to be_a(EvilEvents::Core::Broadcasting::Adapters)

          expect(broadcaster.adapters_container[:memory_sync]).to eq(
            EvilEvents::Core::Broadcasting::Adapters::MemorySync
          )

          expect(broadcaster.adapters_container[:memory_async]).to eq(
            EvilEvents::Core::Broadcasting::Adapters::MemoryAsync
          )
        end
      end
    end

    describe 'adapters orchestration' do
      let(:broadcaster) { described_class.new }

      describe '#register_adapter' do
        it 'registers passed adapter object with passed name (name already taken => fails)' do
          rabbit_adapter = double
          resque_adapter = double

          expect { broadcaster.register_adapter(:rabbit, rabbit_adapter) }.not_to raise_error
          expect { broadcaster.register_adapter(:resque, resque_adapter) }.not_to raise_error

          expect { broadcaster.register_adapter(:rabbit, double) }.to(
            raise_error(Dry::Container::Error)
          )

          expect { broadcaster.register_adapter(:resque, double) }.to(
            raise_error(Dry::Container::Error)
          )
        end
      end

      describe '#resolve_adapter' do
        it 'returns registered adapter object by passed event name (not registered => fails)' do
          sidekiq_adapter = double
          que_adapter     = double

          broadcaster.register_adapter(:sidekiq, sidekiq_adapter)
          broadcaster.register_adapter(:que, que_adapter)

          expect(broadcaster.resolve_adapter(:que)).to eq(que_adapter)
          expect(broadcaster.resolve_adapter(:sidekiq)).to eq(sidekiq_adapter)

          expect { broadcaster.resolve_adapter(:keki_peki) }.to raise_error(Dry::Container::Error)
        end
      end
    end
  end

  describe 'notification behavior' do
    let(:broadcaster) { described_class.new }

    describe '#process_event_notification' do
      let(:event_class) { build_event_class }
      let(:event)       { event_class.new }
      let(:manager)     { build_event_manager(event_class) }

      it 'delegates notification process to the internal notifier service' do
        expect(broadcaster.event_notifier).to receive(:notify).with(manager, event)
        broadcaster.process_event_notification(manager, event)
      end
    end

    describe '#restart_event_notifier' do
      it 'delegates the restarting process to the internal notifier service' do
        expect(broadcaster.event_notifier).to receive(:restart!)
        broadcaster.restart_event_notifier
      end
    end
  end

  describe 'interaction interface' do
    describe 'broadcasting behavior' do
      let(:broadcaster) { described_class.new }

      describe '#emit' do
        it 'delegates a broadcasting logic to the internal event emitter' do
          event = double
          default_adapter_identifier = nil
          custom_adapter_identifier = gen_symb

          # default adapter identifier
          expect(broadcaster.event_emitter).to receive(:emit).with(
            event, adapter: default_adapter_identifier
          ).once
          broadcaster.emit(event)

          # custom adapter identifier
          expect(broadcaster.event_emitter).to receive(:emit).with(
            event, adapter: custom_adapter_identifier
          ).once
          broadcaster.emit(event, adapter: custom_adapter_identifier)
        end
      end

      describe '#raw_emit' do
        it 'delegates a raw broadcasting logic to the internal event emitter' do
          event_type  = double
          event_attrs = { id: nil, payload: {}, metadata: {} }

          attrs_with_default_adapter = event_attrs.merge(adapter: nil)
          attrs_with_custom_adapter  = event_attrs.merge(adapter: gen_symb)

          # default adapter identifier
          expect(broadcaster.event_emitter).to(
            receive(:raw_emit).with(event_type, **attrs_with_default_adapter).once
          )
          broadcaster.raw_emit(event_type, **attrs_with_default_adapter)

          # custom adapter identifier
          expect(broadcaster.event_emitter).to(
            receive(:raw_emit).with(event_type, **attrs_with_custom_adapter).once
          )
          broadcaster.raw_emit(event_type, **attrs_with_custom_adapter)
        end
      end
    end

    describe 'broadcasting process' do
      include_context 'event system'

      let(:sidekiq_adapter) { build_adapter_class.new }
      let(:rabbit_adapter)  { build_adapter_class.new }
      let(:broadcaster)     { event_system.broadcaster }

      before do
        event_system.register_adapter(:sidekiq, sidekiq_adapter)
        event_system.register_adapter(:rabbit,  rabbit_adapter)
      end

      describe '#emit' do
        it 'processes event (appropriate adapter should receive corresponding event)' do
          event_class         = build_event_class('broadcaster_works') { adapter :sidekiq }
          another_event_class = build_event_class('emitter_works')     { adapter :rabbit }

          event         = event_class.new
          another_event = another_event_class.new

          expect(sidekiq_adapter).to receive(:call).with(event).once
          expect(rabbit_adapter).to  receive(:call).with(another_event).once

          broadcaster.emit(event)
          broadcaster.emit(another_event)
        end
      end

      describe '#raw_emit' do
        it 'processes event with received event attributes' \
          '(appropriate adapter should receive corresponding event)' do
          build_event_class('saved') do
            payload :a
            payload :b
            adapter :rabbit
          end

          build_event_class('stored') do
            payload :kek, EvilEvents::Types::Strict::Integer.default(1)
            payload :pek, EvilEvents::Types::Strict::String
            adapter :sidekiq
          end

          expect(sidekiq_adapter).to receive(:call).with(
            have_attributes(type: 'stored', payload: match(kek: 1, pek: 'test'))
          ).once

          expect(rabbit_adapter).to receive(:call).with(
            have_attributes(type: 'saved', payload: match(a: 'kek', b: 'pek'))
          ).once

          broadcaster.raw_emit('saved', payload: { a: 'kek', b: 'pek' })
          broadcaster.raw_emit('stored', payload: { pek: 'test' })
        end
      end
    end
  end
end
