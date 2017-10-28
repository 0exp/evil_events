# frozen_string_literal: true

describe EvilEvents::Core::Events::Subscriber::Mixin, :stub_event_system do
  it_behaves_like 'event subscriber component' do
    let(:subscribeable) { Class.new.tap { |klass| klass.include(described_class) }.new }
  end
end
