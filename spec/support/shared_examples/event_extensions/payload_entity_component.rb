# frozen_string_literal: true

# TODO: Dry with <metadata entity component>
shared_examples 'payload entity component' do
  describe 'payload behaviour' do
    describe 'attribute definition DSL' do
      describe '.attribute and initialization' do
        it 'defines a typed instance attribute with constructor affect' do
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
          expect { payload_class.new(payload: { foo: 1 }) }.to raise_error(Dry::Struct::Error)
          expect { payload_class.new(payload: { bar: 2 }) }.to raise_error(Dry::Struct::Error)
          expect { payload_class.new(payload: { foo: 1, bar: 2 }) }.not_to raise_error

          # define new attribute
          expect { payload_class.class_eval { payload :baz } }.not_to raise_error

          # new attribute affects a constructor
          expect { payload_class.new }.to raise_error(Dry::Struct::Error)
          expect { payload_class.new(payload: { foo: 1 }) }.to raise_error(Dry::Struct::Error)
          expect { payload_class.new(payload: { bar: 2 }) }.to raise_error(Dry::Struct::Error)
          expect { payload_class.new(payload: { foo: 1, bar: 2 }) }.to raise_error(Dry::Struct::Error)
          expect { payload_class.new(payload: { foo: 1, bar: 2, baz: 3 }) }.not_to raise_error
          # rubocop:enable Metrics/LineLength

          # define typed attributes (dry-rb implementation)
          payload_class = Class.new(payload_abstraction)
          expect do
            payload_class.class_eval do
              payload :foo, EvilEvents::Types::Int
              payload :bar, EvilEvents::Types::Strict::String.default(proc { 'KEK' })
              payload :baz, EvilEvents::Types::Strict::Bool.default(false)
            end
          end.not_to raise_error

          # fails on attribute duplication due to attribute definition
          payload_class = Class.new(payload_abstraction)
          expect do
            payload_class.class_eval do
              payload :foo, EvilEvents::Types::Int
              payload :foo, EvilEvents::Types::Strict::String.default(proc { 'KEK' })
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
        end
      end
    end

    describe 'instantiation' do
      it 'fails when passed constructor parameters have incopatible type' do
        payload_class = Class.new(payload_abstraction)
        expect do
          payload_class.class_eval do
            payload :amount,   EvilEvents::Types::Int
            payload :currency, EvilEvents::Types::Strict::String.default(proc { 'EUR' })
            payload :done,     EvilEvents::Types::Strict::Bool.default(false)
          end
        end.not_to raise_error

        # valid type cheking
        # can use/reassign defaults explicitly
        expect do
          payload_class.new(payload: { amount: 10, done: true })
        end.not_to raise_error

        # amount can be anything (cuz non-strict)
        expect do
          payload_class.new(payload: { amount: :test })
        end.not_to raise_error

        # can use/reassign defaults explicitly
        expect do
          payload_class.new(payload: { amount: '10', done: false, currency: 'RUB' })
        end.not_to raise_error

        # invalid type checking
        expect do
          # invalid types: :done (non-boolean)
          payload_class.new(payload: { amount: 10, done: 10 })
        end.to raise_error(Dry::Struct::Error)

        expect do
          # invalid types: :currency (non-string), :done (non-boolean)
          payload_class.new(payload: { amount: 10, done: 30, currency: 40 })
        end.to raise_error(Dry::Struct::Error)
      end

      it 'attributes with default-valued types can be ignored due to instantiaton' do
        payload_class = Class.new(payload_abstraction) do
          payload :size, EvilEvents::Types::Strict::Int.default(proc { 123_456 })
          payload :name, EvilEvents::Types::String
          payload :role, EvilEvents::Types::Strict::Symbol.default(proc { :admin })
        end

        # rubocop:disable Metrics/LineLength
        expect { payload_class.new(payload: { name: 'test' }) }.not_to raise_error
        expect { payload_class.new(payload: { name: 'test', size: 10 }) }.not_to raise_error
        expect { payload_class.new(payload: { name: 'test', role: :test }) }.not_to raise_error
        expect { payload_class.new(payload: { name: 'test', size: 10, role: :test }) }.not_to raise_error
        # rubocop:enable Metrics/LineLength
      end
    end
  end
end
