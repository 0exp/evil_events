# frozen_string_literal: true

describe EvilEvents::Core::System::TypeManager, :stub_event_system do
  let(:type_manager) { described_class.new }

  describe 'attributes' do
    describe '#converter' do
      specify { expect(type_manager.converter).to be_a(EvilEvents::Shared::TypeConverter) }
    end
  end

  describe '#register_converter' do
    it 'delegates the converter object registration process to the internal type converter' do
      type, coercer = gen_symb, gen_proc

      expect(type_manager.converter).to(
        receive(:register).with(type, coercer).once do |type_arg, coercer_arg|
          expect(type_arg).to eq(type)
          expect(coercer_arg).to eq(coercer)
        end
      )

      type_manager.register_converter(type, coercer)
    end

    it 'returns a correct delegation result (converter object)' do
      type, coercer = gen_symb, gen_proc
      converter = type_manager.register_converter(type, coercer)

      expect(converter).to be_a(EvilEvents::Shared::TypeConverter::Converter)
      expect(converter.coercer).to eq(coercer)
    end

    specify 'required attributes' do
      expect { type_manager.register_converter }.to raise_error(ArgumentError)
      expect { type_manager.register_converter(gen_symb) }.to raise_error(ArgumentError)
      expect { type_manager.register_converter(&gen_proc) }.to raise_error(ArgumentError)
      expect { type_manager.register_converter(gen_str, gen_proc) }.to raise_error(ArgumentError)
      expect { type_manager.register_converter(gen_symb, gen_proc, &gen_proc) }.not_to raise_error
    end
  end

  describe '#resolve_type' do
    it 'delegates the type resolving process to the internal type converter' do
      type_name = gen_symb
      type_opts = { gen_symb => gen_str, gen_symb => gen_str }

      expect(type_manager.converter).to receive(:resolve_type).with(type_name, **type_opts)

      type_manager.resolve_type(type_name, **type_opts)
    end

    it 'returns a correct delegation result (new coercible type)' do
      type_name = gen_symb
      type_manager.register_converter(type_name, ->(value) { "coerced_#{value}" })

      # checking values
      nil_value, number_value, default_value = nil, gen_int, gen_symb

      # check coercible type behavior without options
      coercible_type = type_manager.resolve_type(type_name)
      expect(coercible_type[nil_value]).to eq("coerced_#{nil_value}")
      expect(coercible_type[number_value]).to eq("coerced_#{number_value}")

      # check coercible type behavior with options
      coercible_type = type_manager.resolve_type(type_name, default: default_value)
      expect(coercible_type[]).to eq(default_value)
      expect(coercible_type[number_value]).to eq("coerced_#{number_value}")
    end
  end
end
