# frozen_string_literal: true

if SpecSupport::Testing.test_native_extensions?
  describe 'Mpacker - MessagePack serialization engine plugin', :stub_event_system do
    EvilEvents::Plugins.load! :mpacker_engine

    include_context 'event system'

    describe 'Mpacker engine usage' do
      it_behaves_like 'messagepack event serialization component' do
        before { system_config.configure { |c| c.serializers.msgpack.engine = :mpacker } }
      end
    end

    describe 'Serializers container dependencies' do
      let(:serializers_container) { EvilEvents::Core::Events::Serializers.new }

      before do
        system_config.configure { |c| c.serializers.msgpack.engine = :mpacker }
        serializers_container.register_core_serializers!
      end

      it 'has correctly instantiated messagpack serializer' do
        expect(serializers_container.resolve(:msgpack)).to be_a(
          EvilEvents::Core::Events::Serializers::MessagePack
        )
      end

      it 'serializer should be memoized' do
        expect(serializers_container.resolve(:msgpack)).to eq(
          serializers_container.resolve(:msgpack)
        )
      end
    end

    describe 'Configuration' do
      let(:config) { EvilEvents::Core::Config.new }

      specify 'default options' do
        expect(config.settings.serializers.msgpack.mpacker.configurator).to be_a(Proc)
      end

      specify 'all meaningful options are configurable' do
        2.times do
          mpacker_configurator = gen_symb

          config.configure do |c|
            c.serializers.msgpack.mpacker.configurator = mpacker_configurator
          end

          expect(config.settings.serializers.msgpack.mpacker.configurator).to eq(
            mpacker_configurator
          )
        end
      end
    end

    describe 'EvilEvents::Core::Events::Serializers::MessagePack::Engines::Mpacker' do
      let(:described_class) { EvilEvents::Core::Events::Serializers::MessagePack::Engines::Mpacker }

      let(:serialization_state) do
        build_serialization_state(
          id:       gen_str,
          type:     gen_str,
          payload:  { gen_symb => gen_str, gen_symb => gen_str },
          metadata: { gen_symb => gen_str, gen_symb => gen_str }
        )
      end

      let(:engine) do
        config = EvilEvents::Core::Events::Serializers::MessagePack::Config.new.tap do |conf|
          conf.settings.options = { mpacker: { configurator: -> (engine) {} } }
        end

        described_class.new(config)
      end

      describe '#dump' do
        it 'returns a string representation of serialization state' do
          expected = ::MessagePack::Factory.new.packer.pack(
            id:       serialization_state.id,
            type:     serialization_state.type,
            payload:  serialization_state.payload,
            metadata: serialization_state.metadata
          ).to_str

          serialization = engine.dump(serialization_state)

          expect(serialization).to be_a(String)
          expect(serialization).to match(expected)
        end

        it 'each invocation returns new string object' do
          first_serialization  = engine.dump(serialization_state)
          second_serialization = engine.dump(serialization_state)

          expect(first_serialization.object_id).not_to eq(second_serialization.object_id)
        end
      end

      describe '#load' do
        context 'when received object is a correct msgpack string' do
          let(:message) { engine.dump(serialization_state) }

          it 'returns serialization state' do
            state = engine.load(message)

            expect(state).to be_a(
              EvilEvents::Core::Events::Serializers::Base::EventSerializationState
            )

            expect(state.id).to eq(serialization_state.id)
            expect(state.type).to eq(serialization_state.type)
            expect(state.payload).to eq(serialization_state.payload)
            expect(state.metadata).to eq(serialization_state.metadata)
          end
        end

        context 'when received object isnt a parsable mpacker string' do
          let(:messages) { gen_all }

          it 'fails with error' do
            messages.each do |message|
              expect { engine.load(message) }.to raise_error(EvilEvents::SerializationEngineError)
            end
          end
        end
      end
    end
  end
end
