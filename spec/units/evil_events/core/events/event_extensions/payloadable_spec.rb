# frozen_string_literal: true

describe EvilEvents::Core::Events::EventExtensions::Payloadable do
  it_behaves_like 'payloadable interface' do
    let(:payloadable_abstraction) do
      build_event_class_signature do |klass|
        klass.include described_class
      end
    end
  end
end
