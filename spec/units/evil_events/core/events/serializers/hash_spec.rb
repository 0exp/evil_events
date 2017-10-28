# frozen_string_literal: true

describe EvilEvents::Core::Events::Serializers::Hash, :stub_event_system do
  include_context 'event system'

  describe '.serialize' do
    context 'when received object is an event instance' do
      it 'returns hash representation of event object with appropriate format' do
        user_registered_event = build_event_class('user_registered') do
          payload :user_id, EvilEvents::Types::Strict::Int
          payload :comment, EvilEvents::Types::Strict::String

          metadata :author_id, EvilEvents::Types::Coercible::Int.default(-1)
          metadata :timestamp
        end.new(
          payload:  { user_id: 100_500, comment: 'thx for registration!' },
          metadata: { timestamp: 55_123 }
        )

        email_received_event = build_event_class('email_received') do
          payload :user_id,  EvilEvents::Types::Strict::Int
          payload :email_id, EvilEvents::Types::Strict::Int
          payload :support,  EvilEvents::Types::Strict::Bool

          metadata :author_id, EvilEvents::Types::Strict::Int.default(-1)
          metadata :timestamp
        end.new(
          payload:  { user_id: 555_666, email_id: 123, support: true },
          metadata: { author_id: 555, timestamp: 123_123 }
        )

        user_registered_serialiation = described_class.serialize(user_registered_event)
        email_received_serialization = described_class.serialize(email_received_event)

        expect(user_registered_serialiation).to match(
          type: 'user_registered',
          metadata: {
            timestamp: 55_123,
            author_id: -1
          },
          payload: {
            user_id: 100_500,
            comment: 'thx for registration!'
          }
        )

        expect(email_received_serialization).to match(
          type: 'email_received',
          metadata: {
            author_id: 555,
            timestamp: 123_123
          },
          payload: {
            email_id: 123,
            user_id:  555_666,
            support:  true
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

    context 'when recevied object is not an event instance' do
      let(:serialization) { described_class.serialize(double) }

      it 'fails with appropriate serialization exception' do
        expect { serialization }.to(
          raise_error(EvilEvents::Core::Events::Serializers::SerializationError)
        )
      end
    end
  end

  describe '.deserialize' do
    let!(:spec_worked_event_class) do
      build_event_class('spec_worked') do
        payload :suite, EvilEvents::Types::Strict::String
        payload :mute,  EvilEvents::Types::Bool

        metadata :uuid, EvilEvents::Types::Strict::Int
      end
    end

    let!(:limit_reached_event_class) do
      build_event_class('limit_reached') do
        payload :current_limit, EvilEvents::Types::Strict::Float
        payload :reached,       EvilEvents::Types::Strict::Float

        metadata :uuid, EvilEvents::Types::Strict::Int
        metadata :desc, EvilEvents::Types::Strict::String
      end
    end

    context 'when received object is a hash' do
      context 'when hash structure has all required fields: -type-, -payload-, -metadata-' do
        it 'delegates event object resloving to the event system and returns its result' do
          serialized_event = {
            type: 'limit_reached',
            payload: {
              current_limit: 100_500.01,
              reached:       100_600.00
            },
            metadata: {
              uuid: 11,
              desc: 'test'
            }
          }

          expect(event_system).to(
            receive(:resolve_event_object).with(
              serialized_event[:type],
              payload:  serialized_event[:payload],
              metadata: serialized_event[:metadata]
            )
          )
          described_class.deserialize(serialized_event)

          deserialization_result = double
          allow(event_system).to receive(:resolve_event_object).and_return(deserialization_result)
          expect(described_class.deserialize(serialized_event)).to eq(deserialization_result)
        end

        it 'returns event instance of concrete event class with corresponding attributes' do
          serialized_event = {
            type: 'spec_worked',
            payload: {
              suite: 'current_spec',
              mute:  true
            },
            metadata: {
              uuid: 123
            }
          }

          event = described_class.deserialize(serialized_event)
          expect(event).to          be_a(spec_worked_event_class)
          expect(event.type).to     eq(spec_worked_event_class.type)
          expect(event.payload).to  match(serialized_event[:payload])
          expect(event.metadata).to match(serialized_event[:metadata])

          serialized_event = {
            type: 'limit_reached',
            payload: {
              current_limit: 15_300.01,
              reached:       15_500.55
            },
            metadata: {
              uuid: 555,
              desc: 'special'
            }
          }

          event = described_class.deserialize(serialized_event)
          expect(event).to          be_a(limit_reached_event_class)
          expect(event.type).to     eq(limit_reached_event_class.type)
          expect(event.payload).to  match(serialized_event[:payload])
          expect(event.metadata).to match(serialized_event[:metadata])
        end

        it 'received hash attributes can contain both strings and symbols keys' do
          serialized_events = [
            {
              type: 'limit_reached',
              payload: { current_limit: 15.00, reached: 16.00 },
              metadata: { uuid: 100, desc: 'spec' }
            },

            {
              'type' => 'limit_reached',
              'payload' => { current_limit: 15.00, reached: 16.00 },
              metadata: { uuid: 100, desc: 'spec' }
            },

            {
              'type' => 'limit_reached',
              payload: { current_limit: 15.00, reached: 16.00 },
              'metadata' => { uuid: 100, desc: 'spec' }
            },

            {
              type: 'limit_reached',
              'payload' => { current_limit: 15.00, reached: 16.00 },
              metadata: { uuid: 100, desc: 'spec' }
            },

            {
              type: 'limit_reached',
              'payload' => { 'current_limit' => 15.00, reached: 16.00 },
              'metadata' => { 'uuid' => 100, desc: 'spec' }
            },

            {
              type: 'limit_reached',
              payload: { 'current_limit' => 15.00, 'reached' => 16.00 },
              metadata: { uuid: 100, 'desc' => 'spec' }
            }
          ]

          serialized_events.each do |serialized_event|
            expect { described_class.deserialize(serialized_event) }.not_to raise_error
            expect(described_class.deserialize(serialized_event)).to be_a(limit_reached_event_class)
          end
        end

        context 'when passed hash represents non-existed event' do
          let(:incompatible_hash) do
            { type: 'wow_installed', payload: { user_money: 0.0 }, metadata: {} }
          end

          it 'fails with non-managed-event-class error' do
            expect { described_class.deserialize(incompatible_hash) }.to(
              raise_error(EvilEvents::Core::Events::ManagerRegistry::NonManagedEventClassError)
            )
          end
        end

        context 'when passed hash represents existing event but has incompatible payload' do
          let(:incompatible_hash) do
            { type: 'spec_worked', payload: {}, metadata: {} }
          end

          it 'fails with payload constructor error' do
            expect { described_class.deserialize(incompatible_hash) }.to(
              raise_error(Dry::Struct::Error)
            )
          end
        end
      end

      context 'when hash structure hasnt all required fields: -type-/-payload-/-metadata-' do
        it 'fails with appropriate deserialization error' do
          [
            {},
            { type: 'limit_reached' },
            { payload: {} },
            { metadata: {} }
          ].each do |serialized_event|
            expect { described_class.deserialize(serialized_event) }.to(
              raise_error(EvilEvents::Core::Events::Serializers::DeserializationError)
            )
          end
        end
      end
    end

    context 'when received object isnt a hash' do
      subject(:deserialization) { described_class.deserialize(double) }

      it 'fails with appropriate deserialization error' do
        expect { deserialization }.to(
          raise_error(EvilEvents::Core::Events::Serializers::DeserializationError)
        )
      end
    end
  end
end
