# frozen_string_literal: true

describe EvilEvents::Serializer, :stub_event_system do
  include_context 'event system'

  shared_examples 'deserialization module' do |data_type, tested_method, delegated_method|
    let(:serialized_event) { double }

    it 'delegates event deserialization to the event system' do
      expect(event_system).to receive(delegated_method).with(serialized_event)
      described_class.public_send(tested_method, serialized_event)
    end
  end

  it_behaves_like 'deserialization module', :json,    :load_from_json,    :deserialize_from_json
  it_behaves_like 'deserialization module', :hash,    :load_from_hash,    :deserialize_from_hash
  it_behaves_like 'deserialization module', :xml,     :load_from_xml,     :deserialize_from_xml
  it_behaves_like 'deserialization module', :msgpack, :load_from_msgpack, :deserialize_from_msgpack
end
