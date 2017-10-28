# frozen_string_literal: true

describe EvilEvents::Core::Broadcasting::Dispatcher::Mixin, :stub_event_system do
  it_behaves_like 'event dispatching interface' do
    let(:dispatcher) { Module.new.tap { |mod| mod.extend(described_class) } }
  end
end
