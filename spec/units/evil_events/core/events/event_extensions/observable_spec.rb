# frozen_string_literal: true

describe EvilEvents::Core::Events::EventExtensions::Observable do
  it_behaves_like 'observable interface' do
    let(:observable) do
      build_event_class_stub do |klass|
        klass.include described_class
      end
    end
  end
end
