# frozen_string_literal: true

describe EvilEvents::Config::Types, :stub_event_system do
  include_context 'event system'

  let(:type_config) { described_class }

  describe '.define_converter' do
    it 'delegates the registration of the converter object to the event system' do
      type_name    = gen_symb
      type_coercer = gen_proc

      expect(event_system).to receive(:register_converter).with(type_name, type_coercer).once

      type_config.define_converter(type_name, &type_coercer)
    end

    it 'registers new coercible type with passed name' do
      expect do # try to use non-registered coercible types
        build_event_class('test') do
          payload  :test, :boolean
          metadata :test, :float
        end
      end.to raise_error(Dry::Container::Error)

      # register coercible types
      type_config.define_converter(:boolean, &gen_proc)
      type_config.define_converter(:float,   &gen_proc)

      expect do # try to use previously non-registered coercible types
        build_event_class('test') do
          payload  :test, :boolean
          metadata :test, :float
        end
      end.not_to raise_error
    end

    it 'fails when converter with passed name is already registered' do
      type_name = gen_symb

      expect do # register
        type_config.define_converter(type_name, &gen_proc)
      end.not_to raise_error

      expect do # try again
        type_config.define_converter(type_name, &gen_proc)
      end.to raise_error(Dry::Container::Error)
    end
  end

  describe '.resolve_type' do
    it 'delegates the resolving of new type to the event system' do
      type_name    = gen_symb
      type_options = { gen_symb => gen_seed, gen_symb => gen_seed }

      expect(event_system).to receive(:resolve_type).with(type_name, **type_options).once

      type_config.resolve_type(type_name, **type_options)
    end

    it 'returns a new type object based on registered coercer' do
      # constraints for the first type
      type_name    = gen_symb
      type_coercer = ->(value) { value.to_s }

      # constraints for the second type
      another_type_name     = gen_symb
      another_type_coercer  = ->(value) { value.to_i }
      another_default_value = gen_int

      # register converters
      type_config.define_converter(type_name, &type_coercer)
      type_config.define_converter(another_type_name, &another_type_coercer)

      # generate types
      type         = type_config.resolve_type(type_name)
      another_type = type_config.resolve_type(another_type_name, default: another_default_value)

      # expected data
      simple_number = gen_int
      stringified_number = simple_number.to_s

      # check coercing logic + check default behavior (not defined => returns nil)
      expect(type[simple_number]).to eq(type_coercer.call(simple_number))
      expect(type[nil]).to eq(type_coercer.call(nil))

      # check coercing logic + check default behaviour (defined => returns the predefined value)
      expect(another_type[stringified_number]).to eq(simple_number)
      expect(another_type[]).to eq(another_default_value)
    end

    it 'fails when a coercer with required type name isnt registered' do
      type_name    = gen_symb
      type_coercer = gen_proc

      another_type_name    = gen_symb
      another_type_coercer = gen_proc

      # check type (fail) => register type => recheck (success)
      expect { type_config.resolve_type(type_name) }.to raise_error(Dry::Container::Error)
      type_config.define_converter(type_name, &type_coercer)
      expect { type_config.resolve_type(type_name) }.not_to raise_error

      # check another type (fail) => register another type => recheck (success)
      expect { type_config.resolve_type(another_type_name) }.to raise_error(Dry::Container::Error)
      type_config.define_converter(another_type_name, &another_type_coercer)
      expect { type_config.resolve_type(another_type_name) }.not_to raise_error
    end
  end
end
