# frozen_string_literal: true

describe EvilEvents::Core::Events::EventExtensions::ClassSignature do
  it_behaves_like 'class signature interface' do
    let(:event_class) { build_event_class_stub.tap { |klass| klass.include described_class } }
  end
end
