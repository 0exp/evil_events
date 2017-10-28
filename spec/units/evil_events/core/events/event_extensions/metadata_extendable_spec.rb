# frozen_string_literal: true

describe EvilEvents::Core::Events::EventExtensions::MetadataExtendable do
  it_behaves_like 'metadata extendable interface' do
    let(:metadata_extendable_abstraction) do
      build_event_class_signature do |klass|
        klass.include described_class
      end
    end
  end
end
