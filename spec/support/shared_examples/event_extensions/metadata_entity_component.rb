# frozen_string_literal: true

# TODO: Dry with <payload entity component>
shared_examples 'metadata entity component' do
  describe 'metadata behaviour' do
    describe 'metadata definition DSL' do
      describe '.metadata and initialization' do
        it 'defines a typed instance attribute (modifying the constructor)', :stub_event_system do
          metadata_class = Class.new(metadata_abstraction)

          # 'empty' constructor
          expect { metadata_class.new }.not_to raise_error

          # basic metadata definition
          expect do
            metadata_class.class_eval do
              metadata :foo
              metadata :bar
            end
          end.not_to raise_error

          # rubocop:disable Metrics/LineLength
          # defined metadata affects constructor
          expect { metadata_class.new }.to raise_error(Dry::Struct::Error)
          expect { metadata_class.new(metadata: { foo: gen_int }) }.to raise_error(Dry::Struct::Error)
          expect { metadata_class.new(metadata: { bar: gen_int }) }.to raise_error(Dry::Struct::Error)
          expect { metadata_class.new(metadata: { foo: gen_int, bar: gen_int }) }.not_to raise_error

          # define new metadata
          expect { metadata_class.class_eval { metadata :baz } }.not_to raise_error

          # new metadata affects a constructor
          expect { metadata_class.new }.to raise_error(Dry::Struct::Error)
          expect { metadata_class.new(metadata: { foo: gen_int }) }.to raise_error(Dry::Struct::Error)
          expect { metadata_class.new(metadata: { bar: gen_int }) }.to raise_error(Dry::Struct::Error)
          expect { metadata_class.new(metadata: { foo: gen_int, bar: gen_int }) }.to raise_error(Dry::Struct::Error)
          expect { metadata_class.new(metadata: { foo: gen_int, bar: gen_int, baz: gen_int }) }.not_to raise_error
          # rubocop:enable Metrics/LineLength

          # define type converters (TypeConverter API)
          EvilEvents::Core::Bootstrap[:event_system].tap do |system|
            system.register_converter(:string,  proc { |value| value.to_s })
            system.register_converter(:integer, proc { |value| Integer(value) })
          end

          metadata_class = Class.new(metadata_abstraction)
          expect do
            metadata_class.class_eval do
              # Dry::Types API
              metadata :foo, EvilEvents::Types::Integer
              metadata :bar, EvilEvents::Types::Strict::String.default(proc { 'KEK' })
              metadata :baz, EvilEvents::Types::Strict::Bool.default(false)

              # TypeConverter API
              metadata :custom_foo, :string
              metadata :custom_bar, :integer
              metadata :custom_baz, :string,  default: 'test'
              metadata :custom_zet, :integer, default: -> { 'test' }
            end
          end.not_to raise_error

          # fails on metadata attribute duplication due to metadata attribute definition
          metadata_class = Class.new(metadata_abstraction)
          expect do
            metadata_class.class_eval do # only Dry::Types
              metadata :foo, EvilEvents::Types::Integer
              metadata :foo, EvilEvents::Types::Strict::String.default(proc { 'KEK' })
            end
          end.to raise_error(Dry::Struct::RepeatedAttributeError)

          expect do
            metadata_class.class_eval do # only TypeConverter
              metadata :bar, :string
              metadata :bar, :integer
            end
          end.to raise_error(Dry::Struct::RepeatedAttributeError)

          expect do
            metadata_class.class_eval do # both TypeConverter and Dry::Types
              metadata :baz, EvilEvents::Types::Integer
              metadata :baz, :string, default: -> { 'test' }
            end
          end.to raise_error(Dry::Struct::RepeatedAttributeError)
        end
      end

      describe '.metadata_fields' do
        it 'returns names of the all defined metadata attributes' do
          metadata_class = Class.new(metadata_abstraction)

          metadata_class.class_eval { metadata :kek }
          expect(metadata_class.metadata_fields).to contain_exactly(:kek)

          metadata_class.class_eval { metadata :pek }
          expect(metadata_class.metadata_fields).to contain_exactly(:kek, :pek)

          metadata_class.class_eval { metadata :user_id }
          expect(metadata_class.metadata_fields).to contain_exactly(:kek, :pek, :user_id)

          metadata_class.class_eval { metadata :enough }
          expect(metadata_class.metadata_fields).to contain_exactly(:kek, :pek, :user_id, :enough)

          # ...and etc.
        end
      end
    end

    describe 'instantiation' do
      it 'fails when constructor parameters have incopatible type' do
        metadata_class = Class.new(metadata_abstraction)
        expect do
          metadata_class.class_eval do
            metadata :amount,   EvilEvents::Types::Integer
            metadata :currency, EvilEvents::Types::Strict::String.default(proc { 'EUR' })
            metadata :done,     EvilEvents::Types::Strict::Bool.default(false)
          end
        end.not_to raise_error

        # valid type cheking
        # can use/reassign defaults explicitly
        expect do
          metadata_class.new(metadata: { amount: gen_int, done: gen_bool })
        end.not_to raise_error

        # amount can be anything (cuz non-strict)
        expect do
          metadata_class.new(metadata: { amount: gen_symb })
        end.not_to raise_error

        # can use/reassign defaults explicitly
        expect do
          metadata_class.new(metadata: { amount: gen_str, done: gen_bool, currency: gen_str })
        end.not_to raise_error

        # invalid type checking
        expect do
          # invalid types: :done (non-boolean)
          metadata_class.new(metadata: { amount: gen_int, done: gen_int })
        end.to raise_error(Dry::Struct::Error)

        expect do
          # invalid types: :currency (non-string), :done (non-boolean)
          metadata_class.new(metadata: { amount: gen_int, done: gen_int, currency: gen_int })
        end.to raise_error(Dry::Struct::Error)
      end

      it 'attributes with default-valued types can be ignored', :stub_event_system do
        # register custom types (coercible types)
        EvilEvents::Core::Bootstrap[:event_system].tap do |system|
          system.register_converter(:string, proc { |value| value.to_s })
          system.register_converter(:amount, proc { |value| Integer(value) })
        end

        metadata_class = Class.new(metadata_abstraction) do
          metadata :size, EvilEvents::Types::Strict::Integer.default(proc { 123_456 })
          metadata :name, EvilEvents::Types::String
          metadata :role, EvilEvents::Types::Strict::Symbol.default(proc { :admin })
          metadata :path, :string
          metadata :cost, :amount, default: -> { 0 }
        end

        # rubocop:disable Metrics/LineLength
        expect { metadata_class.new(metadata: { name: gen_str, path: gen_str }) }.not_to raise_error
        expect { metadata_class.new(metadata: { name: gen_str, path: gen_str, size: gen_int }) }.not_to raise_error
        expect { metadata_class.new(metadata: { name: gen_str, path: gen_str, role: gen_symb }) }.not_to raise_error
        expect { metadata_class.new(metadata: { name: gen_str, path: gen_str, size: gen_int, role: gen_symb }) }.not_to raise_error
        expect { metadata_class.new(metadata: { name: gen_str, path: gen_str, size: gen_int, role: gen_symb, cost: gen_int }) }.not_to raise_error
        # rubocop:enable Metrics/LineLength
      end
    end
  end
end
