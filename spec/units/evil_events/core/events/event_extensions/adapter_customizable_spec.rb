# frozen_string_literal: true

describe EvilEvents::Core::Events::EventExtensions::AdapterCustomizable do
  it_behaves_like 'adapter customizable interface' do
    let(:customizable) do
      build_event_class_stub do |klass|
        klass.include described_class
      end
    end
  end
end
