# frozen_string_literal: true

shared_examples 'event serializer component' do
  describe 'serializer component behaviour', :stub_event_system do
    let(:serialization_error)   { EvilEvents::SerializationError }
    let(:deserialization_error) { EvilEvents::DeserializationError }

    let!(:event_attributes) do
      {
        id: gen_str,
        type: gen_str,
        metadata: {
          gen_symb(only_letters: true) => gen_str,
          gen_symb(only_letters: true) => gen_int,
          gen_symb(only_letters: true) => gen_float
        },
        payload: {
          gen_symb(only_letters: true) => gen_str,
          gen_symb(only_letters: true) => gen_int,
          gen_symb(only_letters: true) => gen_float
        }
      }
    end

    let!(:event_class) do
      build_event_class(event_attributes[:type]) do
        event_attributes[:payload].each_key do |payload_key|
          payload(payload_key)
        end

        event_attributes[:metadata].each_key do |metadata_key|
          metadata(metadata_key)
        end
      end
    end

    let!(:event) do
      event_class.new(
        id: event_attributes[:id],
        payload: event_attributes[:payload],
        metadata: event_attributes[:metadata]
      )
    end

    describe '#serialize' do
      subject(:serialize) { serializer.serialize(event) }

      context 'when passed object is an event instance' do
        it 'returns corresponding serialization representation' do
          serialization = serializer.serialize(event)
          expect(serialization).to be_a(serialization_type)
        end
      end

      context 'passed object isnt an event instance' do
        let(:event) { gen_all.sample }

        it 'fails with serialization error' do
          expect { serialize }.to raise_error(serialization_error)
        end
      end
    end

    describe '#deserialize' do
      context 'when passed object is a correctly serialized event data' do
        let(:data) { serializer.serialize(event) }

        it 'restores event object' do
          deserialized_event = serializer.deserialize(data)

          expect(deserialized_event).to          be_a(event_class)
          expect(deserialized_event.id).to       eq(event.id)
          expect(deserialized_event.type).to     eq(event.type)
          expect(deserialized_event.metadata).to match(event.metadata)
          expect(deserialized_event.payload).to  match(event.payload)
        end
      end

      context 'when passed object has invalid event serialization state' do
        it 'fails with deserialization error' do
          invalid_serializations.each do |invalid_serialization|
            expect { serializer.deserialize(invalid_serialization) }.to raise_error(
              deserialization_error
            )
          end
        end
      end

      context 'when passed object is incorrect' do
        it 'fails with deserialization error' do
          incorrect_deserialization_objects.each do |incorrect_object|
            expect { serializer.deserialize(incorrect_object) }.to raise_error(
              deserialization_error
            )
          end
        end
      end
    end
  end
end
