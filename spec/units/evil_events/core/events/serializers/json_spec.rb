# frozen_string_literal: true

describe EvilEvents::Core::Events::Serializers::JSON, :stub_event_system do
  include_context 'event system'

  context 'native engine' do
    before { system_config.configure { |c| c.serializers.json.engine = :native } }
    it_behaves_like 'json event serialization component'
  end
end
