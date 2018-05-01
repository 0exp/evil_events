# frozen_string_literal: true

describe EvilEvents::Core::Events::Serializers::Base::EventSerializationState, :stub_event_system do
  describe 'instantiation' do
    specify 'via event' do
      event = build_event_class('test_event') do
        payload :a
        payload :b
        payload :c

        metadata :d
        metadata :e
        metadata :f
      end.new(
        payload:  { a: gen_int, b: gen_str,  c: gen_symb  },
        metadata: { d: gen_str, e: gen_symb, f: gen_float }
      )

      state = described_class.build_from_event(event)

      expect(state.instance_variables).to contain_exactly(:@id, :@type, :@metadata, :@payload)
      expect(state.id).to eq(event.id)
      expect(state.type).to eq(event.type)
      expect(state.metadata).to match(event.metadata)
      expect(state.payload).to  match(event.payload)
    end

    specify 'via options' do
      attributes = { id: gen_str, type: gen_str, payload: {}, metadata: {} }

      state = described_class.build_from_options(**attributes)

      expect(state.instance_variables).to contain_exactly(:@id, :@type, :@metadata, :@payload)
      expect(state.id).to eq(attributes[:id])
      expect(state.type).to eq(attributes[:type])
      expect(state.metadata).to match(attributes[:metadata])
      expect(state.payload).to  match(attributes[:payload])
    end

    specify 'via constructor' do
    end
  end

  describe '#valid?' do
    let(:non_hash_values) do
      [gen_str, gen_symb, gen_int, gen_float, gen_obj, gen_bool, gen_lambda]
    end

    let(:non_string_values) do
      [{}, gen_symb, gen_int, gen_float, gen_obj, gen_bool, gen_lambda]
    end

    let(:valid_attributes) do
      { id: gen_str, type: gen_str, payload: {}, metadata: {} }
    end

    specify 'false when type isnt defined' do
      invalid_attributes = valid_attributes.merge(type: nil)
      state = described_class.new(**invalid_attributes)
      expect(state.valid?).to eq(false)
    end

    specify 'false when payload isnt defined' do
      invalid_attributes = valid_attributes.merge(payload: nil)
      state = described_class.new(**invalid_attributes)
      expect(state.valid?).to eq(false)
    end

    specify 'false when metadata isnt defined' do
      invalid_attributes = valid_attributes.merge(metadata: nil)
      state = described_class.new(**invalid_attributes)
      expect(state.valid?).to eq(false)
    end

    specify 'false when payload isnt a hash' do
      non_hash_values.each do |non_hash|
        invalid_attributes = valid_attributes.merge(payload: non_hash)
        state = described_class.new(**invalid_attributes)
        expect(state.valid?).to eq(false)
      end
    end

    specify 'false when metadata isnt a hash' do
      non_hash_values.each do |non_hash|
        invalid_attributes = valid_attributes.merge(metadata: non_hash)
        state = described_class.new(**invalid_attributes)
        expect(state.valid?).to eq(false)
      end
    end

    specify 'false when type isnt a string' do
      non_string_values.each do |non_string|
        invalid_attributes = valid_attributes.merge(type: non_string)
        state = described_class.new(**invalid_attributes)
        expect(state.valid?).to eq(false)
      end
    end

    specify 'true when type/payload/metadata are correctly defined' do
      state = described_class.new(**valid_attributes)
      expect(state.valid?).to eq(true)
      state = described_class.new(**valid_attributes.merge(id: nil))
      expect(state.valid?).to eq(true)
    end
  end
end
