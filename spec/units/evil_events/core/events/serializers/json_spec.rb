# frozen_string_literal: true

describe EvilEvents::Core::Events::Serializers::JSON, :stub_event_system do
  include_context 'event system'

  describe '.serialize' do
    context 'when receied object is an event instance' do
      it 'returns json representation of event object with appropriate format' do
        keks_signed_in_attrs = {
          id: gen_str,
          payload: { game: gen_str, time: gen_int },
          metadata: { ref_id: gen_int }
        }

        keks_signed_in_event = build_event_class('keks_signed_in') do
          payload :time, EvilEvents::Types::Strict::Int
          payload :game, EvilEvents::Types::Strict::String

          metadata :ref_id, EvilEvents::Types::Strict::Int
        end.new(**keks_signed_in_attrs)

        keks_signed_out_attrs = {
          payload: { time: gen_int, reason: gen_str, metadata: nil }
        }

        keks_signed_out_event = build_event_class('keks_signed_out') do
          payload :time,    EvilEvents::Types::Strict::Int
          payload :reason,  EvilEvents::Types::Strict::String
          payload :metadata

          metadata :author_id, EvilEvents::Types::Any.default(nil)
          metadata :timestamp, EvilEvents::Types::Any.default(nil)
        end.new(**keks_signed_out_attrs)

        keks_signed_in_serialization  = described_class.serialize(keks_signed_in_event)
        keks_signed_out_serialization = described_class.serialize(keks_signed_out_event)

        expect(::JSON.parse(keks_signed_in_serialization)).to match(
          'type' => 'keks_signed_in',
          'id' => keks_signed_in_attrs[:id],
          'metadata' => {
            'ref_id' => keks_signed_in_attrs[:metadata][:ref_id]
          },
          'payload' => {
            'game' => keks_signed_in_attrs[:payload][:game],
            'time' => keks_signed_in_attrs[:payload][:time]
          }
        )

        expect(::JSON.parse(keks_signed_out_serialization)).to match(
          'type' => 'keks_signed_out',
          'id' => keks_signed_out_event.id,
          'metadata' => {
            'author_id' => nil,
            'timestamp' => nil
          },
          'payload' => {
            'metadata' => keks_signed_out_attrs[:payload][:metadata],
            'time' => keks_signed_out_attrs[:payload][:time],
            'reason' => keks_signed_out_attrs[:payload][:reason]
          }
        )
      end

      it 'each invocation provides a new result object (doesnt remember anything)' do
        test_event = build_event_class('test_event').new

        first_serialization  = described_class.serialize(test_event)
        second_serialization = described_class.serialize(test_event)

        expect(first_serialization.object_id).not_to eq(second_serialization.object_id)
      end
    end

    context 'when received object is not an event instance' do
      let(:serialization) { described_class.serialize(double) }

      it 'fails with appropriate serialization exception' do
        expect { serialization }.to(
          raise_error(EvilEvents::SerializationError)
        )
      end
    end
  end

  describe '.deserialize' do
    let!(:keks_won_event_klass) do
      build_event_class('keks_won') do
        payload :score
        payload :rank

        metadata :timestamp
        metadata :uuid
      end
    end

    let!(:keks_lost_event_klass) do
      build_event_class('keks_lost') do
        payload :reason
        payload :rank
        payload :points

        metadata :timestamp
        metadata :uuid
      end
    end

    context 'when received object is a parsable json string' do
      context 'when json structure has all required fields: -type-, -payload-, -metadata-' do
        it 'returns an event instance of a concrete event class with appropriate attributes' do
          serialized_event = {
            type: 'keks_lost',
            metadata: {
              timestamp: gen_int,
              uuid: gen_str
            },
            payload: {
              rank:   gen_str,
              reason: gen_str,
              points: gen_int
            }
          }

          event = described_class.deserialize(::JSON.generate(serialized_event))
          expect(event).to be_a(keks_lost_event_klass)
          expect(event.id).to eq(EvilEvents::Core::Events::EventFactory::UNDEFINED_EVENT_ID)
          expect(event.type).to eq(keks_lost_event_klass.type)
          expect(event.payload).to match(serialized_event[:payload])
          expect(event.metadata).to match(serialized_event[:metadata])

          serialized_event = {
            type: 'keks_won',
            id: gen_str,
            metadata: {
              timestamp: gen_int,
              uuid: gen_int
            },
            payload: {
              score: gen_int,
              rank: gen_str
            }
          }

          event = described_class.deserialize(::JSON.generate(serialized_event))
          expect(event).to          be_a(keks_won_event_klass)
          expect(event.id).to       eq(serialized_event[:id])
          expect(event.type).to     eq(keks_won_event_klass.type)
          expect(event.payload).to  match(serialized_event[:payload])
          expect(event.metadata).to match(serialized_event[:metadata])
        end
      end

      context 'when passed json string represents non-existed event' do
        let(:incompatible_json) do
          ::JSON.generate(
            type: gen_str,
            id: gen_str,
            payload: { gen_symb => gen_bool },
            metadata: { gen_symb => nil }
          )
        end

        it 'fails with non-managed-event-class error' do
          expect { described_class.deserialize(incompatible_json) }.to(
            raise_error(EvilEvents::NonManagedEventClassError)
          )
        end
      end

      context 'when passed json string represents existing event but has incompatible payload' do
        let(:incompatible_json) { ::JSON.generate(type: 'keks_lost', payload: {}, metadata: {}) }

        it 'fails with payload constructor error' do
          expect { described_class.deserialize(incompatible_json) }.to(
            raise_error(Dry::Struct::Error)
          )
        end
      end

      context 'when josn structure hasnt all required fields: -type-/-payload-/-metadata-' do
        it 'fails with appropriate deserialization result' do
          [
            {},
            { type: 'keks_won' },
            { payload: {} },
            { metadata: {} },
            { id: gen_str }
          ].each do |serialized_event|
            expect { described_class.deserialize(serialized_event) }.to(
              raise_error(EvilEvents::DeserializationError)
            )
          end
        end
      end
    end

    context 'when received object isnt a parsable json string' do
      it 'fails with appropriate deserialization error' do
        [double, 'kek', '{}test{}', 'las_-vegas metadata: {}'].each do |serialized_event|
          expect { described_class.deserialize(serialized_event) }.to(
            raise_error(EvilEvents::DeserializationError)
          )
        end
      end
    end
  end
end
