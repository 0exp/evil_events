# frozen_string_literal: true

describe EvilEvents::Core::Events::Serializers::Hash, :stub_event_system do
  include_context 'event system'

  describe '.serialize' do
    context 'when received object is an event instance' do
      it 'returns a hash representation of event object with appropriate format' do
        user_registered_attrs = {
          id: gen_str,
          payload: { user_id: gen_int, comment: gen_str },
          metadata: { timestamp: gen_int }
        }

        user_registered_event = build_event_class('user_registered') do
          payload :user_id, EvilEvents::Types::Strict::Int
          payload :comment, EvilEvents::Types::Strict::String

          metadata :author_id, EvilEvents::Types::Coercible::Int.default(-1)
          metadata :timestamp
        end.new(**user_registered_attrs)

        email_received_event_attrs = {
          payload:  { user_id: gen_int, email_id: gen_int, support: gen_bool },
          metadata: { author_id: gen_int, timestamp: gen_int }
        }

        email_received_event = build_event_class('email_received') do
          payload :user_id,  EvilEvents::Types::Strict::Int
          payload :email_id, EvilEvents::Types::Strict::Int
          payload :support,  EvilEvents::Types::Strict::Bool

          metadata :author_id, EvilEvents::Types::Strict::Int.default(-1)
          metadata :timestamp
        end.new(**email_received_event_attrs)

        user_registered_serialiation = described_class.serialize(user_registered_event)
        email_received_serialization = described_class.serialize(email_received_event)

        expect(user_registered_serialiation).to match(
          type:     'user_registered',
          id:       user_registered_attrs[:id],
          payload:  user_registered_attrs[:payload],
          metadata: user_registered_attrs[:metadata].merge(author_id: -1)
        )

        expect(email_received_serialization).to match(
          id: email_received_event.id,
          type: 'email_received',
          **email_received_event_attrs
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
        expect { serialization }.to raise_error(EvilEvents::SerializationError)
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
        it 'returns event instance of concrete event class with corresponding attributes' do
          serialized_event = {
            type: 'spec_worked',
            payload: {
              suite: gen_str,
              mute:  gen_bool
            },
            metadata: {
              uuid: gen_int
            }
          }

          event = described_class.deserialize(serialized_event)
          expect(event).to be_a(spec_worked_event_class)
          expect(event.id).to eq(EvilEvents::Core::Events::EventFactory::UNDEFINED_EVENT_ID)
          expect(event.type).to eq(spec_worked_event_class.type)
          expect(event.payload).to match(serialized_event[:payload])
          expect(event.metadata).to match(serialized_event[:metadata])

          serialized_event = {
            type: 'limit_reached',
            id: gen_str,
            payload: {
              current_limit: gen_float,
              reached:       gen_float
            },
            metadata: {
              uuid: gen_int,
              desc: gen_str
            }
          }

          event = described_class.deserialize(serialized_event)
          expect(event).to          be_a(limit_reached_event_class)
          expect(event.id).to       eq(serialized_event[:id])
          expect(event.type).to     eq(limit_reached_event_class.type)
          expect(event.payload).to  match(serialized_event[:payload])
          expect(event.metadata).to match(serialized_event[:metadata])
        end

        it 'received hash attributes can contain both strings and symbols keys' do
          serialized_events = [
            {
              id: gen_str,
              type: 'limit_reached',
              payload: { current_limit: gen_float, reached: gen_float },
              metadata: { uuid: gen_int, desc: 'spec' }
            },

            {
              'id' => gen_str,
              'type' => 'limit_reached',
              'payload' => { current_limit: gen_float, reached: gen_float },
              metadata: { uuid: gen_int, desc: 'spec' }
            },

            {
              'type' => 'limit_reached',
              payload: { current_limit: gen_float, reached: gen_float },
              'metadata' => { uuid: gen_int, desc: 'spec' }
            },

            {
              id: gen_str,
              type: 'limit_reached',
              'payload' => { current_limit: gen_float, reached: gen_float },
              metadata: { uuid: gen_int, desc: 'spec' }
            },

            {
              type: 'limit_reached',
              'payload' => { 'current_limit' => gen_float, reached: gen_float },
              'metadata' => { 'uuid' => gen_int, desc: 'spec' }
            },

            {
              'id' => gen_str,
              type: 'limit_reached',
              payload: { 'current_limit' => gen_float, 'reached' => gen_float },
              metadata: { uuid: gen_int, 'desc' => 'spec' }
            }
          ]

          serialized_events.each do |serialized_event|
            expect { described_class.deserialize(serialized_event) }.not_to raise_error
            expect(described_class.deserialize(serialized_event)).to be_a(limit_reached_event_class)
          end
        end

        context 'when passed hash represents non-existed event' do
          let(:incompatible_hash) do
            { id: gen_str, type: gen_str, payload: { gen_symb => gen_float }, metadata: {} }
          end

          it 'fails with non-managed-event-class error' do
            expect { described_class.deserialize(incompatible_hash) }.to(
              raise_error(EvilEvents::NonManagedEventClassError)
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

    context 'when received object isnt a hash' do
      subject(:deserialization) { described_class.deserialize(double) }

      it 'fails with appropriate deserialization error' do
        expect { deserialization }.to(
          raise_error(EvilEvents::DeserializationError)
        )
      end
    end
  end
end
