# frozen_string_literal: true

describe EvilEvents::Core::Events::EventExtensions::Hookable do
  it_behaves_like 'hookable interface' do
    let(:hookable) do
      build_event_class_stub do |klass|
        klass.include described_class
      end
    end
  end
end
