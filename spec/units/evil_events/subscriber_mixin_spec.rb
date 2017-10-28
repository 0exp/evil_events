# frozen_string_literal: true

describe EvilEvents::SubscriberMixin, :stub_event_system do
  it_behaves_like 'event subscriber component' do
    let(:subscribeable) { Class.new.tap { |klass| klass.extend(described_class) } }
  end
end
