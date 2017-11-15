# frozen_string_literal: true

describe EvilEvents::Core::Events::EventExtensions::Payloadable, :stub_event_system do
  it_behaves_like 'payloadable interface' do
    let(:payloadable_abstraction) do
      build_event_class_stub do |klass|
        klass.include described_class
      end
    end
  end
end
