# frozen_string_literal: true

# TODO: Dry with <metadata entity component>
shared_examples 'payload entity component' do
  describe 'payload behaviour' do
    describe 'attribute definition DSL' do
      describe '.attribute and initialization' do
        it 'defines a typed instance attribute (modifying the constructor)', :stub_event_system do
          payload_class = Class.new(payload_abstraction)

          # 'empty' constructor
          expect { payload_class.new }.not_to raise_error

          # basic attributes definition
          expect do
            payload_class.class_eval do
              payload :foo
              payload :bar
            end
          end.not_to raise_error

          # rubocop:disable Metrics/LineLength
          # defined attributes affects constructor
          expect { payload_class.new }.to raise_error(Dry::Struct::Error)
          expect { payload_class.new(payload: { foo: gen_int }) }.to raise_error(Dry::Struct::Error)
          expect { payload_class.new(payload: { bar: gen_int }) }.to raise_error(Dry::Struct::Error)
          expect { payload_class.new(payload: { foo: gen_int, bar: gen_int }) }.not_to raise_error

          # define new attribute
          expect { payload_class.class_eval { payload :baz } }.not_to raise_error

          # new attribute affects a constructor
          expect { payload_class.new }.to raise_error(Dry::Struct::Error)
          expect { payload_class.new(payload: { foo: gen_int }) }.to raise_error(Dry::Struct::Error)
          expect { payload_class.new(payload: { bar: gen_int }) }.to raise_error(Dry::Struct::Error)
          expect { payload_class.new(payload: { foo: gen_int, bar: gen_int }) }.to raise_error(Dry::Struct::Error)
          expect { payload_class.new(payload: { foo: gen_int, bar: gen_int, baz: gen_int }) }.not_to raise_error
          # rubocop:enable Metrics/LineLength

          payload_class = Class.new(payload_abstraction)

          # define type converters (TypeConverter API)
          EvilEvents::Core::Bootstrap[:event_system].tap do |system|
            system.register_converter(:string,  proc { |value| value.to_s })
            system.register_converter(:integer, proc { |value| Integer(value) })
          end

          expect do
            payload_class.class_eval do
              # Dry::Types API
              payload :foo, EvilEvents::Types::Integer
              payload :bar, EvilEvents::Types::Strict::String.default(proc { 'KEK' })
              payload :baz, EvilEvents::Types::Strict::Bool.default(false)

              # TypeConverter API
              payload :custom_foo, :string
              payload :custom_bar, :integer
              payload :custom_baz, :string,  default: 'test'
              payload :custom_zet, :integer, default: -> { 'test' }
            end
          end.not_to raise_error

          # fails on attribute duplication due to attribute definition
          payload_class = Class.new(payload_abstraction)
          expect do
            payload_class.class_eval do # only Dry::Types
              payload :foo, EvilEvents::Types::Integer
              payload :foo, EvilEvents::Types::Strict::String.default(proc { 'KEK' })
            end
          end.to raise_error(Dry::Struct::RepeatedAttributeError)

          expect do
            payload_class.class_eval do # only TypeConverter
              payload :bar, :string
              payload :bar, :integer
            end
          end.to raise_error(Dry::Struct::RepeatedAttributeError)

          expect do
            payload_class.class_eval do # both TypeConverter and Dry::Types
              payload :baz, EvilEvents::Types::Integer
              payload :baz, :string, default: -> { 'test' }
            end
          end.to raise_error(Dry::Struct::RepeatedAttributeError)
        end
      end

      describe '.payload_fields' do
        it 'returns names of the all defined attributes' do
          payload_class = Class.new(payload_abstraction)

          payload_class.class_eval { payload :kek }
          expect(payload_class.payload_fields).to contain_exactly(:kek)

          payload_class.class_eval { payload :pek }
          expect(payload_class.payload_fields).to contain_exactly(:kek, :pek)

          payload_class.class_eval { payload :user_id }
          expect(payload_class.payload_fields).to contain_exactly(:kek, :pek, :user_id)

          payload_class.class_eval { payload :enough }
          expect(payload_class.payload_fields).to contain_exactly(:kek, :pek, :user_id, :enough)

          # ...and etc.
        end
      end
    end

    describe 'instantiation' do
      it 'fails when constructor parameters have incopatible type' do
        payload_class = Class.new(payload_abstraction)
        expect do
          payload_class.class_eval do
            payload :amount,   EvilEvents::Types::Integer
            payload :currency, EvilEvents::Types::Strict::String.default(proc { 'EUR' })
            payload :done,     EvilEvents::Types::Strict::Bool.default(false)
          end
        end.not_to raise_error

        # valid type cheking
        # can use/reassign defaults explicitly
        expect do
          payload_class.new(payload: { amount: gen_int, done: gen_bool })
        end.not_to raise_error

        # amount can be anything (cuz non-strict)
        expect do
          payload_class.new(payload: { amount: gen_symb })
        end.not_to raise_error

        # can use/reassign defaults explicitly
        expect do
          payload_class.new(payload: { amount: gen_str, done: gen_bool, currency: gen_str })
        end.not_to raise_error

        # invalid type checking
        expect do
          # invalid types: :done (non-boolean)
          payload_class.new(payload: { amount: gen_int, done: gen_int })
        end.to raise_error(Dry::Struct::Error)

        expect do
          # invalid types: :currency (non-string), :done (non-boolean)
          payload_class.new(payload: { amount: gen_int, done: gen_int, currency: gen_int })
        end.to raise_error(Dry::Struct::Error)
      end

      it 'attributes with default-valued types can be ignored', :stub_event_system do
        # register custom types (coercible types)
        EvilEvents::Core::Bootstrap[:event_system].tap do |system|
          system.register_converter(:string, proc { |value| value.to_s })
          system.register_converter(:amount, proc { |value| Integer(value) })
        end

        payload_class = Class.new(payload_abstraction) do
          payload :size, EvilEvents::Types::Strict::Integer.default(proc { 123_456 })
          payload :name, EvilEvents::Types::String
          payload :role, EvilEvents::Types::Strict::Symbol.default(proc { :admin })
          payload :path, :string
          payload :cost, :amount, default: -> { 0 }
        end

        # rubocop:disable Metrics/LineLength
        expect { payload_class.new(payload: { name: gen_str, path: gen_str }) }.not_to raise_error
        expect { payload_class.new(payload: { name: gen_str, path: gen_str, size: gen_int }) }.not_to raise_error
        expect { payload_class.new(payload: { name: gen_str, path: gen_str, role: gen_symb }) }.not_to raise_error
        expect { payload_class.new(payload: { name: gen_str, path: gen_str, size: gen_int, role: gen_symb }) }.not_to raise_error
        expect { payload_class.new(payload: { name: gen_str, path: gen_str, size: gen_int, role: gen_symb, cost: gen_int }) }.not_to raise_error
        # rubocop:enable Metrics/LineLength
      end
    end
  end
end
