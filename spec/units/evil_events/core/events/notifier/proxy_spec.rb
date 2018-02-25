# frozen_string_literal: true

describe EvilEvents::Core::Events::Notifier::Proxy do
  describe 'method delegation' do
    let(:proxy) { described_class.new }

    it 'delegates shutdown! / restart! / notify to a notifier' do
      expect(proxy.notifier).to receive(:shutdown!)
      proxy.shutdown!

      expect(proxy.notifier).to receive(:restart!)
      proxy.restart!

      expect(proxy.notifier).to receive(:notify)
      proxy.notify
    end
  end

  describe 'initialization' do
    it 'initializes a notifier object lazily (proxy instance)' do
      expect(EvilEvents::Core::Events::Notifier::Builder).not_to receive(:build_notifier!)
      described_class.new
    end

    it 'initializes a notifier object lazily (notifier instance)' do
      expect(EvilEvents::Core::Events::Notifier::Builder).to receive(:build_notifier!)
      described_class.new.notifier
    end
  end
end
