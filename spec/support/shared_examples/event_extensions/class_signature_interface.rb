# frozen_string_literal: true

shared_examples 'class signature interface' do
  describe 'instance interface' do
    describe '#similar_to?', :stub_event_system do
      let(:event_klass) do
        build_event_class do
          payload :a
          payload :b
          payload :c

          metadata :d
          metadata :e
          metadata :f
        end
      end

      let(:another_event_klass) do
        build_event_class do
          payload :a
          payload :b
          payload :c

          metadata :d
          metadata :e
          metadata :f
        end
      end

      let(:event_attrs) do
        {
          id: gen_str,
          payload: { a: gen_int, b: gen_str, c: gen_symb },
          metadata: { d: gen_float, e: gen_int, f: gen_str }
        }
      end

      let(:event) do
        event_klass.new(
          id:       event_attrs[:id],
          payload:  event_attrs[:payload],
          metadata: event_attrs[:metadata]
        )
      end

      context 'when objects has equal general event attributes' do
        let(:similar_event) do
          event_klass.new(
            id:       event_attrs[:id],
            payload:  event_attrs[:payload],
            metadata: event_attrs[:metadata]
          )
        end

        let(:similar_object) do
          Struct.new(:type, :id, :payload, :metadata).new(
            event_klass.type, *event_attrs.values_at(:id, :payload, :metadata)
          )
        end

        it 'returns true' do
          # event similarity
          expect(event.similar_to?(similar_event)).to eq(true)
          expect(similar_event.similar_to?(event)).to eq(true)

          # object similarity
          expect(event.similar_to?(similar_object)).to         eq(true)
          expect(similar_event.similar_to?(similar_object)).to eq(true)
        end
      end

      context 'when object has no equal general event attributes' do
        it 'returns false' do
          non_similar_event = event_klass.new(
            id: gen_str,
            payload: { a: gen_int, b: gen_str, c: gen_symb },
            metadata: { d: gen_float, e: gen_int, f: gen_str }
          )

          non_similar_id = event_klass.new(
            payload:  event_attrs[:payload],
            metadata: event_attrs[:metadata]
          )

          non_similar_payload = event_klass.new(
            id:       event_attrs[:id],
            payload:  { a: gen_symb, b: gen_int, c: gen_str },
            metadata: event_attrs[:metadata]
          )

          non_similar_metadata = event_klass.new(
            id:       event_attrs[:id],
            payload:  event_attrs[:payload],
            metadata: { d: gen_float, e: gen_int, f: gen_str }
          )

          non_similar_type = another_event_klass.new(
            id:       event_attrs[:id],
            payload:  event_attrs[:payload],
            metadata: event_attrs[:metadata]
          )

          expect(event.similar_to?(non_similar_type)).to     eq(false)
          expect(event.similar_to?(non_similar_event)).to    eq(false)
          expect(event.similar_to?(non_similar_id)).to       eq(false)
          expect(event.similar_to?(non_similar_payload)).to  eq(false)
          expect(event.similar_to?(non_similar_metadata)).to eq(false)
        end
      end

      context 'when similar object has non-equal attribute interface' do
        it 'returns false' do
          non_similar_id = Struct.new(:type, :payload, :metadata).new(
            event_klass.type, *event_attrs.values_at(:payload, :metadata)
          )

          non_similar_payload = Struct.new(:type, :id, :metadata).new(
            event_klass.type, *event_attrs.values_at(:id, :metadata)
          )

          non_similar_metadata = Struct.new(:type, :id, :payload).new(
            event_klass.type, *event_attrs.values_at(:id, :payload)
          )

          non_similar_type = Struct.new(:id, :payload, :metadata).new(
            *event_attrs.values_at(:id, :payload, :metadata)
          )

          non_similar_object = Struct.new(gen_symb, gen_symb).new(gen_int, gen_str)

          expect(event.similar_to?(non_similar_id)).to       eq(false)
          expect(event.similar_to?(non_similar_payload)).to  eq(false)
          expect(event.similar_to?(non_similar_metadata)).to eq(false)
          expect(event.similar_to?(non_similar_type)).to     eq(false)
          expect(event.similar_to?(non_similar_object)).to   eq(false)
        end
      end
    end
  end

  describe 'class signature proxy interface' do
    describe '__creation_strategy__' do
      specify '.__creation_strategy__ accessor' do
        expect(event_class.__creation_strategy__).to eq(nil)

        strategy = gen_symb
        event_class.__creation_strategy__ = strategy

        expect(event_class.__creation_strategy__).to eq(strategy)
      end
    end

    describe '.signature' do
      it 'returns Signature-proxy instance' do
        event_class.signature.tap do |signature|
          expect(signature).to be_a(
            EvilEvents::Core::Events::EventExtensions::ClassSignature::Signature
          )

          expect(signature.event_class).to eq(event_class)
        end
      end
    end
  end
end
