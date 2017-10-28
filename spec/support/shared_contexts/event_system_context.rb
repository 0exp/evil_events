# frozen_string_literal: true

shared_context 'event system' do
  let(:event_system)  { EvilEvents::Core::Bootstrap[:event_system] }
  let(:system_config) { EvilEvents::Core::Bootstrap[:config] }
end
