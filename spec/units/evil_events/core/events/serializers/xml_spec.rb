# frozen_string_literal: true

describe EvilEvents::Core::Events::Serializers::XML, :stub_event_system do
  include_context 'event system'

  describe '.serialize' do
    context 'when received object is an event instance' do
      it 'returns a string representation of an event with a corresponding xml format' do
        # NOTE: this spec depends on Ox library

        event = build_event_class('user_registered') do
          payload :user_id, EvilEvents::Types::Strict::Int
          payload :comment, EvilEvents::Types::Strict::String

          metadata :author_id, EvilEvents::Types::Coercible::Int.default(-1)
          metadata :timestamp
        end.new(
          id: gen_str,
          payload: { user_id: gen_int, comment: gen_str },
          metadata: { timestamp: gen_int }
        )

        serialization_state = described_class::EventSerializationState.new(event)

        expect(Ox.dump(serialization_state)).to eq(described_class.serialize(event))
      end

      it 'each invokation provides a new xml string object (non-cachable)' do
        test_event = build_event_class('test_event').new

        first_serialization  = described_class.serialize(test_event)
        second_serialization = described_class.serialize(test_event)

        expect(first_serialization.object_id).not_to eq(second_serialization.object_id)
      end
    end

    context 'when received object isnt an event instance' do
      subject(:serialization) { described_class.serialize(double) }

      it 'fails with corresponding serialization error' do
        expect { serialization }.to(
          raise_error(EvilEvents::XMLSerializationError)
        )
      end
    end
  end

  describe '.deserialize' do
    let!(:iphone_crashed_event_klass) do
      build_event_class('iphone_crashed') do
        payload :serial_no
        payload :model

        metadata :timestamp
      end
    end

    let!(:iphone_crashed_event) do
      iphone_crashed_event_klass.new(
        payload: {
          serial_no: gen_str,
          model: gen_str
        },
        metadata: { timestamp: gen_int }
      )
    end

    context 'when received object is a parsable xml string' do
      context 'when passed xml representation has all required event fields' do
        let(:xml) { described_class.serialize(iphone_crashed_event) }

        it 'returns an instance of corresponding event' do
          event = described_class.deserialize(xml)

          expect(event).to          be_a(iphone_crashed_event_klass)
          expect(event.id).to       eq(iphone_crashed_event.id)
          expect(event.type).to     eq(iphone_crashed_event.type)
          expect(event.payload).to  match(iphone_crashed_event.payload)
          expect(event.metadata).to match(iphone_crashed_event.metadata)
        end
      end

      context 'when passed xml representation represents non-registered event' do
        let(:xml) do
          described_class
            .serialize(iphone_crashed_event)
            .sub(iphone_crashed_event_klass.type, gen_str)
        end

        it 'fails with corresponding error' do
          expect { described_class.deserialize(xml) }.to raise_error(
            EvilEvents::NonManagedEventClassError
          )
        end
      end

      context 'when passed xml representation has incompatible event payload/matedata attrs' do
        let(:xml) { described_class.serialize(iphone_crashed_event_klass.allocate) }

        it 'fails with payload/metadata constructor error' do
          expect { described_class.deserialize(xml) }.to raise_error(Dry::Struct::Error)
        end
      end
    end

    context 'when received object isnt a parsable xml string' do
      let(:incored_xml_objects) { gen_all }

      it 'fails with corresponding deserialization error' do
        incored_xml_objects.each do |xml|
          expect { described_class.deserialize(xml) }.to raise_error(
            EvilEvents::XMLDeserializationError
          )
        end
      end
    end
  end
end
