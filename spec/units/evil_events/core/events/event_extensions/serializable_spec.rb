# frozen_string_literal: true

describe EvilEvents::Core::Events::EventExtensions::Serializable do
  it_behaves_like 'serializable interface' do
    let(:serializable) do
      build_event_class_signature do |klass|
        klass.include described_class
      end.new
    end
  end
end
