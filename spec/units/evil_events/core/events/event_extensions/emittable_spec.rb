# frozen_string_literal: true

describe EvilEvents::Core::Events::EventExtensions::Emittable do
  it_behaves_like 'emittable interface' do
    let(:emittable) do
      build_event_class_signature do |klass|
        klass.include described_class
      end.new
    end
  end
end
