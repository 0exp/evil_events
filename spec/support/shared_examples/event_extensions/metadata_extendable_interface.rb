# frozen_string_literal: true

# TODO: Dry with <payloadable interface>
shared_examples 'metadata extendable interface' do
  describe 'metadata extendable behaviour' do
    describe 'metadata sub-type intialization' do
      it 'creates a concrete sub-type of an abstract metadata after inheritence' do
        first_event_class  = Class.new(metadata_extendable_abstraction)
        second_event_class = Class.new(metadata_extendable_abstraction)

        expect(first_event_class::Metadata).not_to eq(second_event_class::Metadata)
      end
    end

    describe 'metadata attribute definition DSL' do
      let(:event_class) { Class.new(metadata_extendable_abstraction) }

      describe '#metadata' do
        it 'defines the metadata attribute with a custom type', :stub_event_system do
          # register two coercible types
          EvilEvents::Core::Bootstrap[:event_system].tap do |system|
            system.register_converter(:string,  -> (value) { value.to_s })
            system.register_converter(:integer, -> (value) { value.to_i })
          end

          # define attribute without any strict type
          expect { event_class.metadata :foo }.not_to raise_error
          expect(event_class::Metadata.attribute_names).to contain_exactly(:foo)

          # define attributes with type definitions
          expect do
            # Dry::Types API
            event_class.metadata :bar, EvilEvents::Types::Strict::String
            # TypeConverter API
            event_class.metadata :baz, :string
          end.not_to raise_error
          expect(event_class::Metadata.attribute_names).to contain_exactly(:foo, :bar, :baz)
        end

        it 'delegates the attribute definition process to Metadata', :stub_event_system do
          # using Dry::Types
          common_attr = :amount
          common_type = EvilEvents::Types::Strict::Integer
          expect(event_class::Metadata).to receive(:attribute).with(common_attr, common_type)
          event_class.metadata common_attr, common_type

          # using coercible types
          EvilEvents::Core::Bootstrap[:event_system].tap do |system|
            system.register_converter(:utility, proc { |value| value.to_s })
          end
          coercible_attr = :utility
          expect(event_class::Metadata).to receive(:attribute).with(coercible_attr, anything)
          event_class.metadata coercible_attr, default: -> { 0 }
        end
      end
    end
  end
end
