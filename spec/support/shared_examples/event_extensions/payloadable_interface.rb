# frozen_string_literal: true

# TODO: Dry with <metadata extendable interface>
shared_examples 'payloadable interface' do
  describe 'payloadable behaviour' do
    describe 'payload sub-type intialization' do
      it 'creates a concrete sub-type of an abstract payload after inheritence' do
        first_event_class  = Class.new(payloadable_abstraction)
        second_event_class = Class.new(payloadable_abstraction)

        expect(first_event_class::Payload).not_to eq(second_event_class::Payload)
      end
    end

    describe 'payload attribute definition DSL' do
      let(:event_class) { Class.new(payloadable_abstraction) }

      describe '#attribute' do
        it 'defines payload attribute with a custom type', :stub_event_system do
          # register two coercible types
          EvilEvents::Core::Bootstrap[:event_system].tap do |system|
            system.register_converter(:string,  ->(value) { value.to_s })
            system.register_converter(:integer, ->(value) { value.to_i })
          end

          # define attribute without any strict type
          expect { event_class.payload :foo }.not_to raise_error
          expect(event_class::Payload.attribute_names).to contain_exactly(:foo)

          # define attributes with type definitions
          expect do
            # Dry::Types API
            event_class.payload :bar, EvilEvents::Types::Strict::String
            # TypeConverter API
            event_class.payload :baz, :string
          end.not_to raise_error

          expect(event_class::Payload.attribute_names).to contain_exactly(:foo, :bar, :baz)
        end

        it 'delegates the attribute definition process to Payload', :stub_event_system do
          # using Dry::Types
          common_attr = :amount
          common_type = EvilEvents::Types::Strict::Int
          expect(event_class::Payload).to receive(:attribute).with(common_attr, common_type)
          event_class.payload common_attr, common_type

          # using coercible types
          EvilEvents::Core::Bootstrap[:event_system].tap do |system|
            system.register_converter(:utility, proc { |value| value.to_s })
          end
          coercible_attr = :utility
          expect(event_class::Payload).to receive(:attribute).with(coercible_attr, anything)
          event_class.payload coercible_attr, default: -> { 0 }
        end
      end
    end
  end
end
