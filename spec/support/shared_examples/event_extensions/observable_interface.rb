# frozen_string_literal: true

shared_examples 'observable interface' do
  describe 'observable behaviour', :mock_event_system do
    describe 'observable DSL' do
      describe '.observe' do
        let(:subscriber) { Class.new { def call(event); end; }.new }
        let(:delegator)  { :call }

        it 'receives the subscriber object and the delegation method name' do
          expect { observable.observe(subscriber, delegator: delegator) }.not_to raise_error
          expect { observable.observe(subscriber) }.not_to raise_error
        end

        it 'delegates subscription process to the event system by passing appropriate values' do
          expect(EvilEvents::Core::Bootstrap[:event_system]).to(
            receive(:observe).with(observable, subscriber, delegator).once
          )

          observable.observe(subscriber, delegator: delegator)
        end

        it 'transmits a delegator as a nil value when delegator was not declared' do
          expect(EvilEvents::Core::Bootstrap[:event_system]).to(
            receive(:observe).with(observable, subscriber, nil).once
          )

          observable.observe(subscriber)
        end
      end

      describe '.observers' do
        it 'delegates the subscribers resolving process to the event system by passing itself' do
          expect(EvilEvents::Core::Bootstrap[:event_system]).to(
            receive(:observers).with(observable).once
          )

          observable.observers
        end
      end

      describe '.default_delegator' do
        it 'instantiates the default delegator attribute used for subscriber wrappers' do
          observable.default_delegator :test_call
          expect(observable.default_delegator).to eq(:test_call)

          observable.default_delegator :test_invoke
          expect(observable.default_delegator).to eq(:test_invoke)
        end

        context 'when a delegator parameter was not passed' do
          context 'and hasnt been defined previously' do
            it 'returns globally preconfigured value from a config' do
              EvilEvents::Core::Bootstrap[:config].configure do |config|
                config.subscriber.default_delegator = :exclusive_test
              end

              expect(observable.default_delegator).to eq(:exclusive_test)

              EvilEvents::Core::Bootstrap[:config].configure do |config|
                config.subscriber.default_delegator = :unique_test_call
              end

              expect(observable.default_delegator).to eq(:unique_test_call)
            end
          end

          context 'and has been instantiated previosuly' do
            let(:delegator) { :capture_the_test }

            before { observable.default_delegator delegator }

            it 'returns previously instantiated value' do
              expect(observable.default_delegator).to eq(delegator)
            end

            it 'ignores globally preconfigured value' do
              EvilEvents::Core::Bootstrap[:config].configure do |config|
                config.subscriber.default_delegator = :globall_call
              end

              expect(observable.default_delegator).to eq(delegator)
            end
          end
        end
      end
    end

    describe 'instance extensions' do
      describe '#observers' do
        it 'delegates observers resolving process to the event system' do
          expect { observable.new.observers }.not_to raise_error
          expect(EvilEvents::Core::Bootstrap[:event_system]).to(
            receive(:observers).with(observable)
          )
          observable.new.observers
        end
      end
    end
  end
end
