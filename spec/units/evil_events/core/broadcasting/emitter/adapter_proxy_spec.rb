# frozen_string_literal: true

describe EvilEvents::Core::Broadcasting::Emitter::AdapterProxy do
  describe 'shared interface' do
    context 'without explicit adapter identifier' do
      specify 'identifier returns event\'s pre-configured adapter name'
      specify 'broadcasting works via event\'s pre-configured adapter'
    end

    context 'with explicit adapter identifier' do
      specify 'identifier returns explicitly specified adapter'
      specify 'broadcasting works via explicitly specified adapter'
    end
  end
end
