# frozen_string_literal: true

describe EvilEvents::Core::Broadcasting::Dispatcher, :stub_event_system do
  it_behaves_like 'event dispatching interface' do
    let(:dispatcher) { described_class }
  end
end
