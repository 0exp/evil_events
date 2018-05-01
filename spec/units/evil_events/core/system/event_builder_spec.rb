# frozen_string_literal: true

describe EvilEvents::Core::System::EventBuilder, :stub_event_system do
  include_context 'event system'

  let(:event_builder) { described_class.new }

  # rubocop:disable Metrics/LineLength
  describe 'serialization / deserialization' do
    shared_examples 'serialization logic' do |type, serialization, deserialization|
      let(:serializer) { SpecSupport::DumbEventSerializer }
      let(:event) { double }

      before do
        event_builder.serializers_container.enable_stubs!
        event_builder.serializers_container.stub(type, serializer)
      end

      describe 'serialization' do
        it 'delegates serialization logic to the corresponding serializer' do
          expect(serializer).to receive(:serialize).with(event)
          event_builder.public_send(serialization, event)
        end

        it 'returns serialization result from the corresponding serializer' do
          expect(event_builder.public_send(serialization, event)).to eq(
            SpecSupport::DumbEventSerializer::SERIALIZATION_RESULT
          )
        end
      end

      describe 'deserialization' do
        it 'delegates deserialization logic to the corresponding serializer' do
          expect(serializer).to receive(:deserialize).with(event)
          event_builder.public_send(deserialization, event)
        end

        it 'returns deserialization result form the corresponding serializer' do
          expect(event_builder.public_send(deserialization, event)).to eq(
            SpecSupport::DumbEventSerializer::DESERIALIZATION_RESULT
          )
        end
      end
    end

    it_behaves_like 'serialization logic', :hash,    :serialize_to_hash,    :deserialize_from_hash
    it_behaves_like 'serialization logic', :json,    :serialize_to_json,    :deserialize_from_json
    it_behaves_like 'serialization logic', :xml,     :serialize_to_xml,     :deserialize_from_xml
    it_behaves_like 'serialization logic', :msgpack, :serialize_to_msgpack, :deserialize_from_msgpack
  end
  # rubocop:enable Metrics/LineLength

  describe 'instantiation' do
    let(:event_type) { 'test_event' }
    let(:event_definitions) do
      proc do
        default_delegator :call
        payload :a, EvilEvents::Types::Any
        payload :b, EvilEvents::Types::String
        observe ::Kernel
        observe ::Object, delegator: :new
        adapter :memory_async
      end
    end

    describe '.define_event_class' do
      it 'delegates non-abstract event class creation to EventFactory' do
        expect(EvilEvents::Core::Events::EventFactory).to(
          receive(:create_class).with(event_type).once do |&received_block|
            expect(received_block).to eq(event_definitions)
          end
        )

        event_builder.define_event_class(event_type, &event_definitions)
      end

      it 'returns the correct delegation result (registered event class)' do
        event_class = event_builder.define_event_class(event_type, &event_definitions)

        expect(event_class).to be < EvilEvents::Core::Events::AbstractEvent
        expect(event_system.managed_event?(event_class)).to eq(true)

        expect { event_builder.define_event_class(event_type, &event_definitions) }.to(
          raise_error(EvilEvents::AlreadyManagedEventClassError)
        )
      end

      specify 'required attributes' do
        expect { event_builder.define_event_class }.to raise_error(ArgumentError)
        expect { event_builder.define_event_class(gen_str, double) }.to raise_error(ArgumentError)
        expect { event_builder.define_event_class(gen_str) }.not_to raise_error
        expect { event_builder.define_event_class(gen_str, &gen_proc) }.not_to raise_error
      end
    end

    describe '.define_abstract_event_class' do
      it 'delegates abstract event class creation to EventFactory' do
        expect(EvilEvents::Core::Events::EventFactory).to(
          receive(:create_abstract_class).with(event_type).once
        )

        event_builder.define_abstract_event_class(event_type)
      end

      it 'returns a correct delegation result (unregistered event class)' do
        event_class = event_builder.define_abstract_event_class(event_type)

        expect(event_class).to be < EvilEvents::Core::Events::AbstractEvent
        expect(event_system.managed_event?(event_class)).to eq(false)

        expect { event_builder.define_event_class(event_type) }.not_to raise_error
        expect(event_system.managed_event?(event_class)).to eq(false)
      end

      specify 'required attributes' do
        expect { event_builder.define_event_class }.to raise_error(ArgumentError)
        expect { event_builder.define_event_class(gen_str, double) }.to raise_error(ArgumentError)
        expect { event_builder.define_event_class(gen_str) }.not_to raise_error
        expect { event_builder.define_event_class(gen_str, &gen_proc) }.not_to raise_error
      end
    end
  end
end
