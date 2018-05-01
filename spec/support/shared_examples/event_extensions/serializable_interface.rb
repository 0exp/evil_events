# frozen_string_literal: true

shared_examples 'serializable interface' do
  describe 'serailizable behaviour' do
    shared_examples 'serialization logic' do |serialization_method|
      it 'delegates serialization logic to event system' do
        allow(EvilEvents::Core::Bootstrap[:event_system]).to receive(serialization_method)

        serializable.public_send(serialization_method)

        expect(EvilEvents::Core::Bootstrap[:event_system]).to(
          have_received(serialization_method).with(serializable)
        )
      end
    end

    it_behaves_like 'serialization logic', :serialize_to_hash
    it_behaves_like 'serialization logic', :serialize_to_json
    it_behaves_like 'serialization logic', :serialize_to_xml
    it_behaves_like 'serialization logic', :serialize_to_msgpack
  end
end
