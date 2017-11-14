# frozen_string_literal: true

describe EvilEvents::Core::Events::EventExtensions::ClassSignature::Equalizer do
  let(:event_class) do
    build_event_class(gen_str).tap do |klass|
      klass.default_delegator gen_symb(only_letters: true)
      klass.payload gen_symb(only_letters: true), gen_event_attr_type
      klass.metadata gen_symb(only_letters: true), gen_event_attr_type
      klass.adapter :memory_sync
    end
  end

  let(:another_event_class) do
    Class.new(build_abstract_event_class(gen_str)).tap do |klass|
      klass.default_delegator gen_symb(only_letters: true)

      klass.payload gen_symb(only_letters: true), gen_event_attr_type
      klass.payload gen_symb(only_letters: true), gen_event_attr_type(:strict)

      klass.metadata gen_symb(only_letters: true), gen_event_attr_type
      klass.metadata gen_symb(only_letters: true), gen_event_attr_type(:json)

      klass.adapter :memory_async
    end
  end

  let(:equalizer_with_same_signatures) do
    signature_a = event_class.signature
    signature_b = event_class.signature

    described_class.new(signature_a, signature_b)
  end

  let(:equalizer_with_different_signatures) do
    signature_a = event_class.signature
    signature_b = another_event_class.signature

    described_class.new(signature_a, signature_b)
  end

  shared_examples 'equality behaviour' do |equality_method|
    describe "##{equality_method}" do
      subject { equalizer.public_send(equality_method) }

      context 'signatures with similar payload stmaps' do
        let(:equalizer) { equalizer_with_same_signatures }

        it { is_expected.to eq(true) }
      end

      context 'signatures with different payload stamps' do
        let(:equalizer) { equalizer_with_different_signatures }

        it { is_expected.to eq(false) }
      end
    end
  end

  it_behaves_like 'equality behaviour', :equal_payload?
  it_behaves_like 'equality behaviour', :equal_metadata?
  it_behaves_like 'equality behaviour', :equal_delegator?
  it_behaves_like 'equality behaviour', :equal_adapter?
  it_behaves_like 'equality behaviour', :equal_type_alias?
  it_behaves_like 'equality behaviour', :equal_class?
  it_behaves_like 'equality behaviour', :similar_signatures?
end
