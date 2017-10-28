# frozen_string_literal: true

# TODO: Dry with <payload entity component>
shared_examples 'metadata entity component' do
  describe 'metadata behaviour' do
    describe 'metadata definition DSL' do
      describe '.metadata and initialization' do
        it 'defines a typed instance metadata attribute with constructor affect' do
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
          expect { metadata_class.new(metadata: { foo: 1 }) }.to raise_error(Dry::Struct::Error)
          expect { metadata_class.new(metadata: { bar: 2 }) }.to raise_error(Dry::Struct::Error)
          expect { metadata_class.new(metadata: { foo: 1, bar: 2 }) }.not_to raise_error

          # define new metadata
          expect { metadata_class.class_eval { metadata :baz } }.not_to raise_error

          # new metadata affects a constructor
          expect { metadata_class.new }.to raise_error(Dry::Struct::Error)
          expect { metadata_class.new(metadata: { foo: 1 }) }.to raise_error(Dry::Struct::Error)
          expect { metadata_class.new(metadata: { bar: 2 }) }.to raise_error(Dry::Struct::Error)
          expect { metadata_class.new(metadata: { foo: 1, bar: 2 }) }.to raise_error(Dry::Struct::Error)
          expect { metadata_class.new(metadata: { foo: 1, bar: 2, baz: 3 }) }.not_to raise_error
          # rubocop:enable Metrics/LineLength

          # define typed metadata fields (dry-rb implementation)
          metadata_class = Class.new(metadata_abstraction)
          expect do
            metadata_class.class_eval do
              metadata :foo, EvilEvents::Types::Int
              metadata :bar, EvilEvents::Types::Strict::String.default(proc { 'KEK' })
              metadata :baz, EvilEvents::Types::Strict::Bool.default(false)
            end
          end.not_to raise_error

          # fails on metadata attribute duplication due to metadata attribute definition
          metadata_class = Class.new(metadata_abstraction)
          expect do
            metadata_class.class_eval do
              metadata :foo, EvilEvents::Types::Int
              metadata :foo, EvilEvents::Types::Strict::String.default(proc { 'KEK' })
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
        end
      end
    end

    describe 'instantiation' do
      it 'fails when passed constructor parameters have incopatible type' do
        metadata_class = Class.new(metadata_abstraction)
        expect do
          metadata_class.class_eval do
            metadata :amount,   EvilEvents::Types::Int
            metadata :currency, EvilEvents::Types::Strict::String.default(proc { 'EUR' })
            metadata :done,     EvilEvents::Types::Strict::Bool.default(false)
          end
        end.not_to raise_error

        # valid type cheking
        # can use/reassign defaults explicitly
        expect do
          metadata_class.new(metadata: { amount: 10, done: true })
        end.not_to raise_error

        # amount can be anything (cuz non-strict)
        expect do
          metadata_class.new(metadata: { amount: :test })
        end.not_to raise_error

        # can use/reassign defaults explicitly
        expect do
          metadata_class.new(metadata: { amount: '10', done: false, currency: 'RUB' })
        end.not_to raise_error

        # invalid type checking
        expect do
          # invalid types: :done (non-boolean)
          metadata_class.new(metadata: { amount: 10, done: 10 })
        end.to raise_error(Dry::Struct::Error)

        expect do
          # invalid types: :currency (non-string), :done (non-boolean)
          metadata_class.new(metadata: { amount: 10, done: 30, currency: 40 })
        end.to raise_error(Dry::Struct::Error)
      end

      it 'attributes with default-valued types can be ignored due to instantiaton' do
        metadata_class = Class.new(metadata_abstraction) do
          metadata :size, EvilEvents::Types::Strict::Int.default(proc { 123_456 })
          metadata :name, EvilEvents::Types::String
          metadata :role, EvilEvents::Types::Strict::Symbol.default(proc { :admin })
        end

        # rubocop:disable Metrics/LineLength
        expect { metadata_class.new(metadata: { name: 'test' }) }.not_to raise_error
        expect { metadata_class.new(metadata: { name: 'test', size: 10 }) }.not_to raise_error
        expect { metadata_class.new(metadata: { name: 'test', role: :test }) }.not_to raise_error
        expect { metadata_class.new(metadata: { name: 'test', size: 10, role: :test }) }.not_to raise_error
        # rubocop:enable Metrics/LineLength
      end
    end
  end
end
