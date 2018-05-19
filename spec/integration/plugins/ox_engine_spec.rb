# frozen_string_literal: true

if SpecSupport::Testing.test_native_extensions?
  describe 'Ox - XML serialization engine plugin', :stub_event_system do
    EvilEvents::Plugins.load! :ox_engine

    include_context 'event system'

    describe 'Ox engine usage' do
      it_behaves_like 'xml event serialization component' do
        before { system_config.configure { |c| c.serializers.xml.engine = :ox } }
      end
    end

    describe 'Serializers container dependencies' do
      let(:serializers_container) { EvilEvents::Core::Events::Serializers.new }

      before do
        system_config.configure { |c| c.serializers.xml.engine = :ox }
        serializers_container.register_core_serializers!
      end

      it 'has correctly instantiated xml serializer' do
        expect(serializers_container.resolve(:xml)).to be_a(
          EvilEvents::Core::Events::Serializers::XML
        )
      end

      it 'serailizer should be memoized' do
        expect(serializers_container.resolve(:xml)).to eq(
          serializers_container.resolve(:xml)
        )
      end
    end

    describe 'EvilEvents::Core::Events::Serializers::XML::Engines::Ox' do
      let(:described_class) { EvilEvents::Core::Events::Serializers::XML::Engines::Ox }

      let(:serialization_state) do
        build_serialization_state(
          id: gen_str,
          type: gen_str,
          payload: { gen_symb => gen_str, gen_symb => gen_str },
          metadata: { gen_symb => gen_str, gen_symb => gen_str }
        )
      end

      let(:engine) do
        config = EvilEvents::Core::Events::Serializers::XML::Config.new
        described_class.new(config)
      end

      describe '#dump' do
        it 'returns xml representation of serialization state based on Ox library' do
          expected_xml_string = ::Ox.dump(serialization_state)
          serialization = engine.dump(serialization_state)

          expect(serialization).to be_a(String)
          expect(serialization).to match(expected_xml_string)
        end

        it 'each invocation provides a new xml string' do
          first_serialization  = engine.dump(serialization_state)
          secont_serialization = engine.dump(serialization_state)

          expect(first_serialization.object_id).not_to eq(secont_serialization.object_id)
        end
      end

      describe '#load' do
        context 'when received object is a correct xml string' do
          let(:xml) { engine.dump(serialization_state) }

          it 'returns serialization state' do
            state = engine.load(xml)

            expect(state).to be_a(
              EvilEvents::Core::Events::Serializers::Base::EventSerializationState
            )

            expect(state.id).to eq(serialization_state.id)
            expect(state.type).to eq(serialization_state.type)
            expect(state.payload).to eq(serialization_state.payload)
            expect(state.metadata).to eq(serialization_state.metadata)
          end
        end

        context 'when received object isnt a parsable xml string' do
          let(:xmls) { gen_all }

          it 'fails with error' do
            xmls.each do |xml|
              expect { engine.load(xml) }.to raise_error(EvilEvents::SerializationEngineError)
            end
          end
        end
      end
    end
  end
end
