# frozen_string_literal: true

describe EvilEvents::DispatcherMixin do
  it_behaves_like 'event dispatching interface' do
    let(:dispatcher) { Class.new.tap { |klass| klass.include(described_class) }.new }
  end
end
