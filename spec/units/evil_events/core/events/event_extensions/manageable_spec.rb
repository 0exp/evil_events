# frozen_string_literal: true

describe EvilEvents::Core::Events::EventExtensions::Manageable do
  it_behaves_like 'manageable interface' do
    let(:manageable) do
      build_event_class_stub do |klass|
        klass.include described_class
      end
    end
  end
end
