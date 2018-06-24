# frozen_string_literal: true

shared_examples 'dispatchable interface' do
  describe 'adapter customizable behaviour', :stub_event_system do
    let(:redis_adapter)   { double }
    let(:que_adapter)     { double }
    let(:sidekiq_adapter) { double }

    before do
      EvilEvents::Core::Bootstrap[:event_system].register_adapter(:redis, redis_adapter)
      EvilEvents::Core::Bootstrap[:event_system].register_adapter(:que, que_adapter)
      EvilEvents::Core::Bootstrap[:event_system].register_adapter(:sidekiq, sidekiq_adapter)
    end

    describe 'adapter-customizable DSL' do
      describe '.adapter' do
        it 'configures event adapter with a passed attribute (adapter name) and returns it' do
          expect(dispatchable.adapter(:redis)).to eq(redis_adapter) # ==> configure
          expect(dispatchable.adapter).to         eq(redis_adapter) # and use

          expect(dispatchable.adapter(:que)).to eq(que_adapter) # ==> re-configure
          expect(dispatchable.adapter).to       eq(que_adapter) # ==> and use
        end

        context 'when adapter with passed name has not been registered' do
          subject(:reigstering) { dispatchable.adapter :resque }

          it 'fails with appropriate error related with non-registered dependency' do
            expect { reigstering }.to raise_error(Dry::Container::Error)
          end
        end

        context 'when adapter identifier parameter was not passed' do
          context 'and hasnt been defined previously' do
            it 'uses globally preconfigured adapter identifier (from the global config)' do
              EvilEvents::Core::Bootstrap[:config].configure do |config|
                config.adapter.default = :redis
              end

              expect(dispatchable.adapter).to eq(redis_adapter)

              EvilEvents::Core::Bootstrap[:config].configure do |config|
                config.adapter.default = :que
              end

              expect(dispatchable.adapter).to eq(que_adapter)
            end
          end

          context 'and has been defined previously' do
            before { dispatchable.adapter :que }

            it 'uses already defined adapter name' do
              expect(dispatchable.adapter).to eq(que_adapter)
            end

            it 'ignores globally preconfigured adapter identifier' do
              EvilEvents::Core::Bootstrap[:config].configure do |config|
                config.adapter.default = :redis
              end

              expect(dispatchable.adapter).to eq(que_adapter)
            end
          end
        end
      end

      describe '.adapter_name' do
        it 'returns an adapter identifier which configured in #adapter method' do
          dispatchable.adapter :redis
          expect(dispatchable.adapter_name).to eq(:redis)

          dispatchable.adapter :que
          expect(dispatchable.adapter_name).to eq(:que)
        end

        it 'returns globally preconfigured value if adapter is not defined' do
          EvilEvents::Core::Bootstrap[:config].configure do |config|
            config.adapter.default = :redis
          end

          expect(dispatchable.adapter_name).to eq(:redis)

          EvilEvents::Core::Bootstrap[:config].configure do |config|
            config.adapter.default = :sidekiq
          end

          expect(dispatchable.adapter_name).to eq(:sidekiq)
        end
      end
    end

    describe 'instance extensions' do
      let(:event_object) { dispatchable.new }

      describe '#adapter' do
        context 'when adapter has been pre-configured on a class' do
          before { dispatchable.adapter :redis }

          it 'returns adapter object which has been configured previously on class' do
            expect(event_object.adapter).to eq(redis_adapter)
          end

          it 'reconfigured adapter affects the #adapter method of an instance' do
            dispatchable.adapter :sidekiq
            expect(event_object.adapter).to eq(sidekiq_adapter)

            dispatchable.adapter :que
            expect(event_object.adapter).to eq(que_adapter)
          end
        end

        context 'when adapter hasnt been pre-configured on a class' do
          it 'returns globally pre-configured default adapter' do
            EvilEvents::Core::Bootstrap[:config].configure do |config|
              config.adapter.default = :sidekiq
            end

            expect(event_object.adapter).to eq(sidekiq_adapter)

            EvilEvents::Core::Bootstrap[:config].configure do |config|
              config.adapter.default = :que
            end

            expect(event_object.adapter).to eq(que_adapter)
          end
        end
      end

      describe '#adapter_name' do
        it 'returns an adapter name which has been configured previously on a type' do
          EvilEvents::Core::Bootstrap[:config].configure do |config|
            config.adapter.default = :sidekiq
          end
          expect(event_object.adapter_name).to eq(:sidekiq) # default

          EvilEvents::Core::Bootstrap[:config].configure do |config|
            config.adapter.default = :que
          end
          expect(event_object.adapter_name).to eq(:que) # re-configured default

          dispatchable.adapter :sidekiq # configurated (non-default)
          expect(event_object.adapter_name).to eq(:sidekiq)

          dispatchable.adapter :redis # re-configurated (non-default)
          expect(event_object.adapter_name).to eq(:redis)
        end
      end
    end
  end

  describe 'event invocation behaviour', :mock_event_system do
    describe '#emit!' do
      it 'delegates event handling process to the event system' do
        event_object = dispatchable.new

        # default explicit adapter identifier
        default_adapter_identifier = nil
        expect(EvilEvents::Core::Bootstrap[:event_system]).to(
          receive(:emit).with(event_object, adapter: default_adapter_identifier).once
        )
        event_object.emit!

        # custom explicit adapter identifier
        custom_adapter_identifier = gen_symb
        expect(EvilEvents::Core::Bootstrap[:event_system]).to(
          receive(:emit).with(event_object, adapter: custom_adapter_identifier).once
        )
        event_object.emit!(adapter: custom_adapter_identifier)
      end
    end

    describe '.emit!' do
      it 'creates new event and invokes emition process for the new created event' do
        expected_id = gen_int

        # generate payload keys
        expected_payload = {
          gen_symb(only_letters: true) => gen_int,
          gen_symb(only_letters: true) => gen_str
        }

        # generate metadata keys
        expected_metadata = {
          gen_symb(only_letters: true) => gen_str,
          gen_symb(only_letters: true) => gen_int
        }

        default_adapter_identifier = nil
        custom_adapter_identifier = gen_symb

        dispatchable.instance_eval do |klass|
          expected_payload.each_key do |payload_key|
            # describe payload attributes
            klass.payload payload_key
          end

          expected_metadata.each_key do |metadata_key|
            # describe metadata attributes
            klass.metadata metadata_key
          end
        end

        # with default adapter identifier
        expect(EvilEvents::Core::Bootstrap[:event_system]).to(
          receive(:emit).with(
            have_attributes(
              id:       expected_id,
              payload:  expected_payload,
              metadata: expected_metadata
            ),
            adapter: default_adapter_identifier
          ).once
        )

        dispatchable.emit!(
          id:       expected_id,
          payload:  expected_payload,
          metadata: expected_metadata
        )

        # with castom adapter identifier
        expect(EvilEvents::Core::Bootstrap[:event_system]).to(
          receive(:emit).with(
            have_attributes(
              id:       expected_id,
              payload:  expected_payload,
              metadata: expected_metadata
            ),
            adapter: custom_adapter_identifier
          ).once
        )

        dispatchable.emit!(
          id:       expected_id,
          payload:  expected_payload,
          metadata: expected_metadata,
          adapter:  custom_adapter_identifier
        )
      end
    end
  end
end
