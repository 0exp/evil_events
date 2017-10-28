# frozen_string_literal: true

shared_examples 'type aliasing interface' do
  describe 'DSL extensions' do
    describe '.type' do
      it 'fails when a function argument (type_name) has incopatible type (non-nil/non-string)' do
        expect { pseudo_identifiable.type(:test) }.to raise_error(
          described_class::IncopatibleEventTypeError
        )

        expect { pseudo_identifiable.type(Object) }.to raise_error(
          described_class::IncopatibleEventTypeError
        )

        expect { pseudo_identifiable.type(100_500) }.to raise_error(
          described_class::IncopatibleEventTypeError
        )

        expect { pseudo_identifiable.type('test') }.not_to raise_error
        expect { pseudo_identifiable.type }.not_to         raise_error
      end

      it 'fails when we tries to redefine the already defined type name' do
        pseudo_identifiable.type 'event_alias'
        expect { pseudo_identifiable.type 'another_event_alias' }.to raise_error(
          described_class::EventTypeAlreadyDefinedError
        )
      end

      it 'fails when we tries to get the non-defined type name' do
        expect { pseudo_identifiable.type }.to raise_error(
          described_class::EventTypeNotDefinedError
        )
      end

      it 'registrates the type name with passed string if type name was not defined previously' do
        expect { pseudo_identifiable.type('test_event_alias') }.not_to raise_error
        expect(pseudo_identifiable.type).to eq('test_event_alias')
      end

      it 'returns the defined type name after the correct definition and getting operations' do
        expect(pseudo_identifiable.type('final_event_alias')).to eq('final_event_alias')
        expect(pseudo_identifiable.type).to eq('final_event_alias')
      end
    end
  end

  describe 'instance extensions' do
    describe '#type' do
      it 'returns the previously defined type defined on a class' do
        pseudo_identifiable.type 'super_mega_test_alias'

        # check that all instances has the same type alias
        expect(pseudo_identifiable.new.type).to eq('super_mega_test_alias')
        expect(pseudo_identifiable.new.type).to eq('super_mega_test_alias')
      end
    end
  end
end
