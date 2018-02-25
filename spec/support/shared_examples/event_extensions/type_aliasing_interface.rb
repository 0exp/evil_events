# frozen_string_literal: true

shared_examples 'type aliasing interface' do
  describe 'DSL extensions' do
    describe '.type' do
      it 'fails when a function argument (type_name) has incopatible type (non-nil/non-string)' do
        expect { pseudo_identifiable.type(gen_symb) }.to raise_error(
          EvilEvents::IncopatibleEventTypeError
        )

        expect { pseudo_identifiable.type(gen_class) }.to raise_error(
          EvilEvents::IncopatibleEventTypeError
        )

        expect { pseudo_identifiable.type(gen_int) }.to raise_error(
          EvilEvents::IncopatibleEventTypeError
        )

        expect { pseudo_identifiable.type(gen_str) }.not_to raise_error
        expect { pseudo_identifiable.type }.not_to raise_error
      end

      it 'fails when we tries to redefine the already defined type name' do
        pseudo_identifiable.type gen_str
        expect { pseudo_identifiable.type gen_str }.to raise_error(
          EvilEvents::EventTypeAlreadyDefinedError
        )
      end

      it 'fails when we tries to get the non-defined type name' do
        expect { pseudo_identifiable.type }.to raise_error(
          EvilEvents::EventTypeNotDefinedError
        )
      end

      it 'registrates a type name with passed string if type name was not defined previously' do
        random_type_name = gen_str

        expect { pseudo_identifiable.type(random_type_name) }.not_to raise_error
        expect(pseudo_identifiable.type).to eq(random_type_name)
      end

      it 'returns the defined type name after the correct definition and getting operations' do
        random_type_name = gen_str

        expect(pseudo_identifiable.type(random_type_name)).to eq(random_type_name)
        expect(pseudo_identifiable.type).to eq(random_type_name)
      end
    end
  end

  describe 'instance extensions' do
    describe '#type' do
      it 'returns the previously defined type defined on a class' do
        type_name = gen_str

        pseudo_identifiable.type type_name

        # check that all instances has the same type alias
        expect(pseudo_identifiable.new.type).to eq(type_name)
        expect(pseudo_identifiable.new.type).to eq(type_name)
      end
    end
  end
end
