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
        it 'defines payload attribute with a custom type' do
          expect { event_class.payload :foo }.not_to raise_error
          expect(event_class::Payload.attribute_names).to contain_exactly(:foo)

          expect do
            event_class.payload :bar, EvilEvents::Types::Strict::String
          end.not_to raise_error
          expect(event_class::Payload.attribute_names).to contain_exactly(:foo, :bar)
        end

        it 'delegates attribute definition process to Payload' do
          attribute_name = :amount
          attribute_type = EvilEvents::Types::Strict::Int

          expect(event_class::Payload).to receive(:attribute).with(attribute_name, attribute_type)

          event_class.payload attribute_name, attribute_type
        end
      end
    end
  end
end
