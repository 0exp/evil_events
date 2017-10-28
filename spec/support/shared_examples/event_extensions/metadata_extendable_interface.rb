# frozen_string_literal: true

# TODO: Dry with <payloadable interface>
shared_examples 'metadata extendable interface' do
  describe 'metadata extendable behaviour' do
    describe 'metadata sub-type intialization' do
      it 'creates a concrete sub-type of an abstract payload after inheritence' do
        first_event_class  = Class.new(metadata_extendable_abstraction)
        second_event_class = Class.new(metadata_extendable_abstraction)

        expect(first_event_class::Metadata).not_to eq(second_event_class::Metadata)
      end
    end

    describe 'metadata attribute definition DSL' do
      let(:event_class) { Class.new(metadata_extendable_abstraction) }

      describe '#metadata' do
        it 'defines metadata attribute with a custom type' do
          expect { event_class.metadata :foo }.not_to raise_error
          expect(event_class::Metadata.attribute_names).to contain_exactly(:foo)

          expect do
            event_class.metadata :bar, EvilEvents::Types::Strict::String
          end.not_to raise_error
          expect(event_class::Metadata.attribute_names).to contain_exactly(:foo, :bar)
        end

        it 'delegates attribute definition process to Metadata' do
          attribute_name = :amount
          attribute_type = EvilEvents::Types::Strict::Int

          expect(event_class::Metadata).to receive(:attribute).with(attribute_name, attribute_type)

          event_class.metadata attribute_name, attribute_type
        end
      end
    end
  end
end
