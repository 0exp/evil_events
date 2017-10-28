# frozen_string_literal: true

describe EvilEvents::Core::Events::Manager::SubscriberList do
  let(:subscriber_list) { described_class.new }

  specify 'a descendant of Concurrent::Array' do
    expect(described_class).to be < Concurrent::Array
  end

  describe 'subscriber-related interface' do
    let(:raw_subscriber) { double }

    describe '#registered?' do
      subject { subscriber_list.registered?(raw_subscriber) }

      context 'when passed raw subscriber has a subscriber wrapper in a list' do
        before { subscriber_list << EvilEvents::Core::Events::Subscriber.new(raw_subscriber) }

        it { is_expected.to eq(true) }
      end

      context 'when passed raw subscriber has no wrapper in a list' do
        it { is_expected.to eq(false) }
      end
    end

    describe '#wrapper_of' do
      context 'when wrapper for passed raw subscriber is exists' do
        before { subscriber_list << EvilEvents::Core::Events::Subscriber.new(raw_subscriber) }

        it 'returns a subscriber wrapper of passed raw subscriber object' do
          wrapper = subscriber_list.wrapper_of(raw_subscriber)

          expect(wrapper).to be_a(EvilEvents::Core::Events::Subscriber)
          expect(wrapper.source_object).to eq(raw_subscriber)
        end
      end

      context 'when wrapper for passed raw subscriber doesnt exists' do
        it 'returns nil' do
          wrapper = subscriber_list.wrapper_of(raw_subscriber)
          expect(wrapper).to eq(nil)
        end
      end
    end

    describe '#sources' do
      let(:first_raw_subscriber)  { double }
      let(:second_raw_subscriber) { double }
      let(:third_raw_subscriber)  { double }

      it 'returns a collection of raw subscribers' do
        expect(subscriber_list.sources).to be_empty

        subscriber_list << EvilEvents::Core::Events::Subscriber.new(first_raw_subscriber)
        expect(subscriber_list.sources).to contain_exactly(first_raw_subscriber)

        subscriber_list << EvilEvents::Core::Events::Subscriber.new(second_raw_subscriber)
        expect(subscriber_list.sources).to contain_exactly(
          first_raw_subscriber, second_raw_subscriber
        )

        subscriber_list << EvilEvents::Core::Events::Subscriber.new(third_raw_subscriber)
        expect(subscriber_list.sources).to contain_exactly(
          first_raw_subscriber, second_raw_subscriber, third_raw_subscriber
        )
      end
    end
  end
end
