# frozen_string_literal: true

describe EvilEvents::Core::Events::Serializers::Hash, :stub_event_system do
  include_context 'event system'

  context 'native engine' do
    before { system_config.configure { |c| c.serializers.hashing.engine = :native } }

    it_behaves_like 'hash event serialization component'
  end
end
