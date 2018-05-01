# frozen_string_literal: true

describe EvilEvents::Core::Events::Serializers::Hash::Engines::Native do
  let(:serialization_state) do
    build_serialization_state(
      id: gen_str,
      type: gen_str,
      payload: { gen_symb => gen_str, gen_symb => gen_str },
      metadata: { gen_symb => gen_str, gen_symb => gen_str }
    )
  end

  let(:engine) do
    config = EvilEvents::Core::Events::Serializers::Hash::Config.new
    described_class.new(config)
  end

  describe '#dump' do
    it 'returns hash representation of event serialization state' do
      native_hash_dump = {
        id:       serialization_state.id,
        type:     serialization_state.type,
        payload:  serialization_state.payload,
        metadata: serialization_state.metadata
      }

      serialization = engine.dump(serialization_state)

      expect(serialization).to be_a(Hash)
      expect(serialization).to match(native_hash_dump)
    end
  end

  describe '#load' do
    specify 'works correctly with string keys and symbol keys; nested should be symbolized' do
      states = [
        {
          id: gen_str,
          type: gen_str,
          payload: { current_limit: gen_float, reached: gen_float },
          metadata: { uuid: gen_int, desc: gen_str }
        },

        {
          'id' => gen_str,
          'type' => gen_str,
          'payload' => { current_limit: gen_float, reached: gen_float },
          metadata: { uuid: gen_int, desc: gen_str }
        },

        {
          'type' => gen_str,
          payload: { current_limit: gen_float, reached: gen_float },
          'metadata' => { uuid: gen_int, desc: gen_str }
        },

        {
          id: gen_str,
          type: gen_str,
          'payload' => { current_limit: gen_float, reached: gen_float },
          metadata: { uuid: gen_int, desc: gen_str }
        },

        {
          type: gen_str,
          'payload' => { 'current_limit' => gen_float, reached: gen_float },
          'metadata' => { 'uuid' => gen_int, desc: gen_str }
        },

        {
          'id' => gen_str,
          type: gen_str,
          payload: { 'current_limit' => gen_float, 'reached' => gen_float },
          metadata: { uuid: gen_int, 'desc' => gen_str }
        }
      ]

      states.each do |state|
        serialization_state = engine.load(state)

        id = state[:id] || state['id']
        type = state[:type] || state['type']

        payload = begin
          pld = state[:payload] || state['payload']
          current_limit = pld[:current_limit] || pld['current_limit']
          reached = pld[:reached] || pld['reached']

          { current_limit: current_limit, reached: reached }
        end

        metadata = begin
          mtd = state[:metadata] || state['metadata']
          uuid = mtd[:uuid] || mtd['uuid']
          desc = mtd[:desc] || mtd['desc']

          { uuid: uuid, desc: desc }
        end

        expect(serialization_state.id).to eq(id)
        expect(serialization_state.type).to eq(type)
        expect(serialization_state.payload).to match(payload)
        expect(serialization_state.metadata).to match(metadata)
      end
    end

    context 'with correct dump' do
      let(:dump) { engine.dump(serialization_state) }

      it 'returns valid serialization state object with corresponding internal state' do
        state = engine.load(dump)

        expect(state).to be_a(EvilEvents::Core::Events::Serializers::Base::EventSerializationState)
        expect(state.id).to eq(serialization_state.id)
        expect(state.type).to eq(serialization_state.type)
        expect(state.payload).to eq(serialization_state.payload)
        expect(state.metadata).to eq(serialization_state.metadata)
        expect(state.valid?).to eq(true)
      end
    end

    context 'with incorrect dump' do
      let(:incorrect_dumps) do
        [gen_str, gen_symb, gen_int, gen_float, gen_obj, gen_bool, gen_lambda]
      end

      it 'fails with error' do
        incorrect_dumps.each do |dump|
          expect { engine.load(dump) }.to raise_error(EvilEvents::SerializationEngineError)
        end
      end
    end

    context 'with partially defined dump' do
      let!(:partial_dumps) do
        state_data = {
          id: gen_str,
          type: gen_str,
          metadata: { gen_symb => gen_str },
          paylaod: { gen_symb => gen_str }
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

      it 'returns invalid serialization state' do
        partial_dumps.each do |partial_dump|
          state = engine.load(partial_dump)
          expect(state.valid?).to eq(false)
          partial_dump.each_pair do |key, value|
            expect(state.public_send(key)).to eq(value)
          end
        end
      end
    end
  end
end
