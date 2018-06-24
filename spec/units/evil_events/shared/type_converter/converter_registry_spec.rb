# frozen_string_literal: true

describe EvilEvents::Shared::TypeConverter::ConverterRegistry do
  let(:registry) { described_class.new }

  describe 'public interface' do
    describe '#converters' do
      it 'returns the internal registry object (with empty state)' do
        internal_registry = registry.converters

        expect(internal_registry).to be_a(EvilEvents::Shared::DependencyContainer)
        expect(internal_registry._container).to be_empty
      end
    end

    describe '#register/#resolve' do
      it 'registers a new convertion object based on the passed clojure' do
        test_key    = gen_symb
        another_key = gen_symb

        test_coercer    = -> (value) { value.to_s }
        another_coercer = proc { |value| value.to_s }

        expect { registry.register(test_key, test_coercer) }.not_to raise_error
        expect { registry.register(another_key, another_coercer) }.not_to raise_error

        expect(registry.resolve(test_key)).to be_a(EvilEvents::Shared::TypeConverter::Converter)
        expect(registry.resolve(another_key)).to be_a(EvilEvents::Shared::TypeConverter::Converter)

        expect(registry.resolve(test_key).coercer).to eq(test_coercer)
        expect(registry.resolve(another_key).coercer).to eq(another_coercer)
      end

      it 'fails when type name isnt a symbol and/or convertion object isnt a proc' do
        invalid_type_names = [gen_int, gen_str, gen_obj, gen_bool]

        invalid_type_names.each do |type_name|
          expect { registry.register(type_name, -> {}) }.to raise_error(ArgumentError)
        end

        expect { registry.register(gen_symb) }.to raise_error(ArgumentError)
        expect { registry.register(gen_symb, -> {}) }.not_to raise_error
      end

      it 'fails when you try to register an object with already registered name' do
        first_key  = gen_symb
        second_key = gen_symb

        expect { registry.register(first_key,  -> {}) }.not_to raise_error
        expect { registry.register(second_key, -> {}) }.not_to raise_error

        expect { registry.register(first_key,  -> {}) }.to raise_error(Dry::Container::Error)
        expect { registry.register(second_key, -> {}) }.to raise_error(Dry::Container::Error)
      end
    end
  end
end
