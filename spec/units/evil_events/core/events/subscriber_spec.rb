# frozen_string_literal: true

describe EvilEvents::Core::Events::Subscriber do
  describe 'shared interface' do
    describe '#delegator' do
      it 'returns delegator method name via delegator resolver evaluation process' do
        source_subscriber  = double
        resolver_clojure   = -> { :test_method }
        delegator_resolver = EvilEvents::Shared::DelegatorResolver.new(resolver_clojure)
        subscriber         = described_class.new(source_subscriber, delegator_resolver)

        expect(subscriber.delegator).to eq(:test_method)
      end

      it 'memoizes calculated delegator method' do
        source_subscriber  = double
        method_prefix      = 'test'
        resolver_clojure   = -> { (method_prefix += '_method').to_sym }
        delegator_resolver = EvilEvents::Shared::DelegatorResolver.new(resolver_clojure)
        subscriber         = described_class.new(source_subscriber, delegator_resolver)

        expect(subscriber.delegator).to eq(:test_method)
        expect(subscriber.delegator).to eq(:test_method)
      end
    end

    describe '#source_object' do
      it 'returns a source subscriber obeject received due to instantiation process' do
        source_subscriber = double
        subscriber = described_class.new(source_subscriber, double)
        expect(subscriber.source_object).to eq(source_subscriber)
      end
    end

    describe '#delegator_resolver' do
      it 'returns a delegator resolver received due to instantiation process' do
        delegator_resolver = double
        subscriber = described_class.new(double, delegator_resolver)
        expect(subscriber.delegator_resolver).to eq(delegator_resolver)
      end
    end

    describe '#notify' do
      let(:source_subscriber)  { Class.new { def test_method(test_event); end }.new }
      let(:delegator_resolver) { EvilEvents::Shared::DelegatorResolver.new(-> { :test_method }) }
      let(:subscriber)         { described_class.new(source_subscriber, delegator_resolver) }

      it 'delegates received event to the source subscriber via calculated delegator method' do
        event = double
        expect(source_subscriber).to receive(:test_method).with(event)
        subscriber.notify(event)
      end
    end
  end
end
