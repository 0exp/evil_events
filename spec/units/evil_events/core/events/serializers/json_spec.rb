# frozen_string_literal: true

describe EvilEvents::Core::Events::Serializers::JSON, :stub_event_system do
  include_context 'event system'

  describe '.serialize' do
    context 'when receied object is an event instance' do
      it 'returns json representation of event object with appropriate format' do
        keks_signed_in_event = build_event_class('keks_signed_in') do
          payload :time, EvilEvents::Types::Strict::Int
          payload :game, EvilEvents::Types::Strict::String

          metadata :ref_id, EvilEvents::Types::Strict::Int
        end.new(payload: { game: 'overwatch', time: 123_456 }, metadata: { ref_id: 100 })

        keks_signed_out_event = build_event_class('keks_signed_out') do
          payload :time,    EvilEvents::Types::Strict::Int
          payload :reason,  EvilEvents::Types::Strict::String
          payload :metadata

          metadata :author_id, EvilEvents::Types::Any.default(nil)
          metadata :timestamp, EvilEvents::Types::Any.default(nil)
        end.new(payload: { time: 555_666, reason: 'dunno', metadata: nil })

        keks_signed_in_serialization  = described_class.serialize(keks_signed_in_event)
        keks_signed_out_serialization = described_class.serialize(keks_signed_out_event)

        expect(::JSON.parse(keks_signed_in_serialization)).to match(
          'type' => 'keks_signed_in',
          'metadata' => {
            'ref_id' => 100
          },
          'payload' => {
            'game' => 'overwatch',
            'time' => 123_456
          }
        )

        expect(::JSON.parse(keks_signed_out_serialization)).to match(
          'type' => 'keks_signed_out',
          'metadata' => {
            'author_id' => nil,
            'timestamp' => nil
          },
          'payload' => {
            'metadata' => nil,
            'time' => 555_666,
            'reason' => 'dunno'
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
          raise_error(EvilEvents::Core::Events::Serializers::SerializationError)
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
        it 'delegates event object resolving to the event system and returns its result' do
          serialized_event = {
            type: 'keks_won',
            metadata: {
              timestamp: 15_923,
              uuid: 'kek1-pek2'
            },
            payload: {
              score: 100_500,
              rank: 'grandmaster'
            }
          }

          jsoned_serialization = ::JSON.generate(serialized_event)

          expect(event_system).to(
            receive(:resolve_event_object).with(
              serialized_event[:type],
              payload:  serialized_event[:payload],
              metadata: serialized_event[:metadata]
            )
          )
          described_class.deserialize(jsoned_serialization)

          deserialization_result = double
          allow(event_system).to receive(:resolve_event_object).and_return(deserialization_result)
          expect(described_class.deserialize(jsoned_serialization)).to eq(deserialization_result)
        end

        it 'returns an event instance of a concrete event class with appropriate attributes' do
          serialized_event = {
            type: 'keks_lost',
            metadata: {
              timestamp: 14_231,
              uuid: 'babah-123'
            },
            payload: {
              rank:   'gold',
              reason: 'stupid teammates',
              points: 765
            }
          }

          event = described_class.deserialize(::JSON.generate(serialized_event))
          expect(event).to          be_a(keks_lost_event_klass)
          expect(event.type).to     eq(keks_lost_event_klass.type)
          expect(event.payload).to  match(serialized_event[:payload])
          expect(event.metadata).to match(serialized_event[:metadata])

          serialized_event = {
            type: 'keks_won',
            metadata: {
              timestamp: 14_764,
              uuid: 55_664
            },
            payload: {
              score: 777,
              rank: 'progamer'
            }
          }

          event = described_class.deserialize(::JSON.generate(serialized_event))
          expect(event).to          be_a(keks_won_event_klass)
          expect(event.type).to     eq(keks_won_event_klass.type)
          expect(event.payload).to  match(serialized_event[:payload])
          expect(event.metadata).to match(serialized_event[:metadata])
        end
      end

      context 'when passed json string represents non-existed event' do
        let(:incompatible_json) do
          ::JSON.generate(
            type: 'keks_reborn',
            payload: { really: true },
            metadata: { superposition: nil }
          )
        end

        it 'fails with non-managed-event-class error' do
          expect { described_class.deserialize(incompatible_json) }.to(
            raise_error(EvilEvents::Core::Events::ManagerRegistry::NonManagedEventClassError)
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
          [{}, { type: 'keks_won' }, { payload: {} }, { metadata: {} }].each do |serialized_event|
            expect { described_class.deserialize(serialized_event) }.to(
              raise_error(EvilEvents::Core::Events::Serializers::DeserializationError)
            )
          end
        end
      end
    end

    context 'when received object isnt a parsable json string' do
      it 'fails with appropriate deserialization error' do
        [double, 'kek', '{}test{}', 'las_-vegas metadata: {}'].each do |serialized_event|
          expect { described_class.deserialize(serialized_event) }.to(
            raise_error(EvilEvents::Core::Events::Serializers::DeserializationError)
          )
        end
      end
    end
  end
end
