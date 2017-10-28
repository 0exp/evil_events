# frozen_string_literal: true

shared_examples 'adapter customizable interface' do
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
          expect(customizable.adapter(:redis)).to eq(redis_adapter) # ==> configure
          expect(customizable.adapter).to         eq(redis_adapter) # and use

          expect(customizable.adapter(:que)).to eq(que_adapter) # ==> re-configure
          expect(customizable.adapter).to       eq(que_adapter) # ==> and use
        end

        context 'when adapter with passed name has not been registered' do
          subject(:reigstering) { customizable.adapter :resque }

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

              expect(customizable.adapter).to eq(redis_adapter)

              EvilEvents::Core::Bootstrap[:config].configure do |config|
                config.adapter.default = :que
              end

              expect(customizable.adapter).to eq(que_adapter)
            end
          end

          context 'and has been defined previously' do
            before { customizable.adapter :que }

            it 'uses already defined adapter name' do
              expect(customizable.adapter).to eq(que_adapter)
            end

            it 'ignores globally preconfigured adapter identifier' do
              EvilEvents::Core::Bootstrap[:config].configure do |config|
                config.adapter.default = :redis
              end

              expect(customizable.adapter).to eq(que_adapter)
            end
          end
        end
      end

      describe '.adapter_name' do
        it 'returns an adapter identifier which configured in #adapter method' do
          customizable.adapter :redis
          expect(customizable.adapter_name).to eq(:redis)

          customizable.adapter :que
          expect(customizable.adapter_name).to eq(:que)
        end

        it 'returns globally preconfigured value if adapter is not defined' do
          EvilEvents::Core::Bootstrap[:config].configure do |config|
            config.adapter.default = :redis
          end

          expect(customizable.adapter_name).to eq(:redis)

          EvilEvents::Core::Bootstrap[:config].configure do |config|
            config.adapter.default = :sidekiq
          end

          expect(customizable.adapter_name).to eq(:sidekiq)
        end
      end
    end

    describe 'instance extensions' do
      let(:event_object) { customizable.new }

      describe '#adapter' do
        context 'when adapter has been pre-configured on a class' do
          before { customizable.adapter :redis }

          it 'returns adapter object which has been configured previously on class' do
            expect(event_object.adapter).to eq(redis_adapter)
          end

          it 'reconfigured adapter affects the #adapter method of an instance' do
            customizable.adapter :sidekiq
            expect(event_object.adapter).to eq(sidekiq_adapter)

            customizable.adapter :que
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

          customizable.adapter :sidekiq # configurated (non-default)
          expect(event_object.adapter_name).to eq(:sidekiq)

          customizable.adapter :redis # re-configurated (non-default)
          expect(event_object.adapter_name).to eq(:redis)
        end
      end
    end
  end
end
