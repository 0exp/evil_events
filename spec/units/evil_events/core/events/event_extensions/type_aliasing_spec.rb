# frozen_string_literal: true

describe EvilEvents::Core::Events::EventExtensions::TypeAliasing do
  it_behaves_like 'type aliasing interface' do
    let(:pseudo_identifiable) do
      build_event_class_stub do |klass|
        klass.include described_class
      end
    end
  end
end
