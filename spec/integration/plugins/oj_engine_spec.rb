# frozen_string_literal: true
if SpecSupport::Testing.test_native_extensions?
  describe 'Oj - JSON serialization engine plugin', :stub_event_system do
    EvilEvents::Plugins.load! :oj_engine

    include_context 'event system'

    describe 'Oj engine usage' do
      it_behaves_like 'json event serialization component' do
        before { system_config.configure { |c| c.serializers.json.engine = :oj } }
      end
    end

    describe 'Serializers container dependencies' do
      let(:serializers_container) { EvilEvents::Core::Events::Serializers.new }

      before do
        system_config.configure { |c| c.serializers.xml.engine = :oj }
        serializers_container.register_core_serializers!
      end

      it 'has correctly instantiated xml serializer' do
        expect(serializers_container.resolve(:json)).to be_a(
          EvilEvents::Core::Events::Serializers::JSON
        )
      end

      it 'serailizer should be memoized' do
        expect(serializers_container.resolve(:json)).to eq(
          serializers_container.resolve(:json)
        )
      end
    end

    describe 'EvilEvents::Core::Events::Serializers::JSON::Engines::Oj' do
      let(:described_class) { EvilEvents::Core::Events::Serializers::JSON::Engines::Oj }

      let(:serialization_state) do
        build_serialization_state(
          id:       gen_str,
          type:     gen_str,
          payload:  { gen_symb => gen_str, gen_symb => gen_str },
          metadata: { gen_symb => gen_str, gen_symb => gen_str }
        )
      end

      let(:engine) do
        config = EvilEvents::Core::Events::Serializers::JSON::Config.new
        described_class.new(config)
      end

      describe '#dump' do
        it 'returns json representation of event serialization state' do
          oj_dump = ::Oj.dump(
            id:       serialization_state.id,
            type:     serialization_state.type,
            payload:  serialization_state.payload,
            metadata: serialization_state.metadata
          )

          serialization = engine.dump(serialization_state)

          expect(serialization).to be_a(String)
          expect(serialization).to match(oj_dump)
        end

        it 'each invocation returns new string object' do
          first_deserialization  = engine.dump(serialization_state)
          second_deserialization = engine.dump(serialization_state)

          expect(first_deserialization.object_id).not_to eq(second_deserialization.object_id)
        end
      end

      describe '#load' do
        context 'with correct dump' do
          let(:dump) { engine.dump(serialization_state) }

          it 'returns an event serialization state object with corresponding internal state' do
            state = engine.load(dump)

            expect(state).to be_a(
              EvilEvents::Core::Events::Serializers::Base::EventSerializationState
            )

            expect(state.id).to eq(serialization_state.id)
            expect(state.type).to eq(serialization_state.type)
            expect(state.payload).to eq(serialization_state.payload)
            expect(state.metadata).to eq(serialization_state.metadata)
          end
        end

        context 'with incorrect dump' do
          let(:dumps) { gen_all }

          it 'fails with error' do
            dumps.each do |dump|
              expect { engine.load(dump) }.to raise_error(EvilEvents::SerializationEngineError)
            end
          end
        end

        context 'with partially defined dump' do
          let!(:partial_dumps) do
            state_data = {
              id:       gen_str,
              type:     gen_str,
              metadata: { gen_symb => gen_str },
              paylaod:  { gen_symb => gen_str }
            }

            key_mappings = (
              %i[id type metadata payload].combination(1).to_a |
              %i[id type metadata payload].combination(2).to_a |
              %i[id type metadata payload].combination(3).to_a |
              %i[id type metadata payload].combination(4).to_a
            )

            key_mappings.map do |key_map|
              state_data.each_pair.each_with_object({}) do |(key, value), partial_dump|
                partial_dump[key] = value if key_map.include?(key)
              end
            end
          end

          it 'returns invald serialization state' do
            partial_dumps.each do |partial_dump|
              jsoned_partial_dump = ::JSON.generate(partial_dump)
              state = engine.load(jsoned_partial_dump)
              expect(state.valid?).to eq(false)
              partial_dump.each_pair do |key, value|
                expect(state.public_send(key)).to eq(value)
              end
            end
          end
        end
      end
    end
  end
end
# rubocop:enable RSpec/EmptyLineAfterExampleGroup
