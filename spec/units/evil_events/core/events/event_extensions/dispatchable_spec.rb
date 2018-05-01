# frozen_string_literal: true

describe EvilEvents::Core::Events::EventExtensions::Dispatchable do
  it_behaves_like 'dispatchable interface' do
    let(:dispatchable) do
      build_event_class_mock.tap do |klass|
        klass.include described_class
      end
    end
  end
end
