# frozen_string_literal: true

describe EvilEvents::Shared::TypeConverter do
  let(:type_converter) { described_class.new }

  describe 'public interface' do
    describe '#register/#resolve' do
      specify 'converter registration' do
        {
          gen_symb => gen_lambda,
          gen_symb => gen_proc
        }.each_pair do |type_name, coercer|
          expect { type_converter.resolve_type(type_name) }.to raise_error(Dry::Container::Error)
          expect { type_converter.register(type_name, coercer) }.not_to raise_error
          expect { type_converter.resolve_type(type_name) }.not_to raise_error
        end
      end

      specify 'converter object (after registration)' do
        type, coercer = gen_symb, gen_proc
        converter = type_converter.register(type, coercer)

        expect(converter).to be_a(EvilEvents::Shared::TypeConverter::Converter)
        expect(converter.coercer).to eq(coercer)
      end

      specify 'type resolving with type builder options' do
        type_key = gen_symb
        type_converter.register(type_key, ->(value) { value.to_s })

        raw_value   = gen_int
        raw_default = gen_str

        # without options
        custom_type = type_converter.resolve_type(type_key)
        expect(custom_type[raw_value]).to eq(raw_value.to_s)
        expect(custom_type[nil]).to eq('')

        # with default option as a primitive
        custom_type_with_default = type_converter.resolve_type(
          type_key, default: raw_default
        )
        expect(custom_type_with_default[raw_value]).to eq(raw_value.to_s)
        expect(custom_type_with_default[nil]).to eq(raw_default)

        # with default option as a proc
        custom_type_with_proc_default = type_converter.resolve_type(
          type_key, default: -> { raw_default }
        )
        expect(custom_type_with_proc_default[raw_value]).to eq(raw_value.to_s)
        expect(custom_type_with_proc_default[nil]).to eq(raw_default)
      end
    end
  end
end
