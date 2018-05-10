# frozen_string_literal: true

describe EvilEvents::Shared::TypeConverter::Converter do
  describe 'initialization' do
    it 'fails when non-proc converter object is provided' do
      [gen_str, gen_float, gen_int, gen_obj, gen_symb].each do |converter|
        expect { described_class.new(converter) }.to raise_error(ArgumentError)
      end

      expect { described_class.new(-> {}) }.not_to raise_error
      expect { described_class.new(proc {}) }.not_to raise_error
    end
  end

  describe 'public interface' do
    describe '#convert' do
      it 'executes the internal converter with a passed value' do
        int   = gen_int
        float = gen_float
        str   = gen_str
        obj   = gen_obj

        multiplier = described_class.new(->(value) { value * 2 })
        expect(multiplier.convert(int)).to    eq(int * 2)
        expect(multiplier.convert(float)).to  eq(float * 2)
        expect(multiplier.convert(str)).to    eq("#{str}#{str}")
        expect { multiplier.convert(obj) }.to raise_error(NoMethodError)

        stringifier = described_class.new(->(value) { value.to_s })
        expect(stringifier.convert(int)).to   eq(int.to_s)
        expect(stringifier.convert(float)).to eq(float.to_s)
        expect(stringifier.convert(str)).to   eq(str)
        expect(stringifier.convert(obj)).to   eq(obj.to_s)
      end
    end

    describe '#transform_to_type' do
      context 'common behaviour' do
        it 'transforms the internal converter object to a type o.O' do
          values = [gen_str, gen_float, gen_int, gen_obj, gen_symb]

          converter = described_class.new(->(value) { value.to_s })
          type = converter.transform_to_type
          values.each { |value| expect(type[value]).to eq(converter.convert(value)) }

          converter = described_class.new(->(value) { value.object_id })
          type = converter.transform_to_type
          values.each { |value| expect(type[value]).to eq(converter.convert(value)) }
        end
      end

      context 'with otions' do
        specify ':default' do
          values = [gen_str, gen_float, gen_int, gen_obj, gen_symb]
          default_value = values.sample

          # default as a value
          converter = described_class.new(->(value) { value.to_s })
          type = converter.transform_to_type(default: default_value)

          values.each do |value|
            expect(type[]).to eq(default_value)
            expect(type[value]).to eq(converter.convert(value))
          end

          # default as a proc
          converter = described_class.new(->(value) { value.to_s })
          type = converter.transform_to_type(default: -> { default_value })

          values.each do |value|
            expect(type[]).to eq(default_value)
            expect(type[value]).to eq(converter.convert(value))
          end
        end
      end
    end
  end
end
