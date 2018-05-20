# frozen_string_literal: true

describe EvilEvents::Core::Events::EventExtensions::ClassSignature::Signature do
  describe 'signature stamps', :stub_event_system do
    describe '#event_class' do
      it 'returns proxified event class' do
        event_class = build_event_class(gen_str)
        signature   = described_class.new(event_class)

        expect(signature.event_class).to eq(event_class)
      end
    end

    describe '#payload_stmap / #metadata_stamp' do
      shared_examples 'structure stamp' do |structure_type, stamp_method|
        specify "#{structure_type} stamp" do
          # check on empty payload
          event_class = build_event_class(gen_str)
          signature   = described_class.new(event_class)

          expect(signature.public_send(stamp_method)).to eq({})

          # check payload with one attribute
          event_class.public_send(structure_type, :uuid, EvilEvents::Types::String)
          signature = described_class.new(event_class)

          expect(signature.public_send(stamp_method)).to match(
            uuid: EvilEvents::Types::String
          )

          # check payload with two attributes
          event_class.public_send(structure_type, :user_id, EvilEvents::Types::Strict::Integer)
          signature = described_class.new(event_class)

          expect(signature.public_send(stamp_method)).to match(
            user_id: EvilEvents::Types::Strict::Integer,
            uuid:    EvilEvents::Types::String
          )

          # check payload with custom types
          EvilEvents::Config.setup_types do |types|
            types.define_converter(:boolan) { |value| !!value }
            types.define_converter(:string, &:to_s)
          end

          event_class.public_send(structure_type, :boolean)
          event_class.public_send(structure_type, :string, default: gen_str)
          signature = described_class.new(event_class)

          expect(signature.public_send(stamp_method)).to match(
            boolean: be_a(Dry::Types::Definition),
            string:  be_a(Dry::Types::Definition),
            user_id: EvilEvents::Types::Strict::Integer,
            uuid:    EvilEvents::Types::String
          )
        end
      end

      it_behaves_like 'structure stamp', :payload,  :payload_stamp
      it_behaves_like 'structure stamp', :metadata, :metadata_stamp
    end

    describe '#class_stamp' do
      subject { described_class.new(event_class).class_stamp }

      context 'block-defined anonymous event class' do
        let(:event_class) { build_event_class(gen_str) }

        it { is_expected.to eq(name: nil, creation_strategy: :proc_eval) }
      end

      context 'block-defined constant-assigned event class' do
        let(:event_const) { gen_str(only_letters: true).capitalize! }
        let(:event_class) { Object.const_get(event_const) }

        before { stub_const(event_const, build_event_class(gen_str)) }

        it { is_expected.to eq(name: event_const, creation_strategy: :proc_eval) }
      end

      context 'class-defined anonymous event class' do
        let(:event_class) { Class.new(build_abstract_event_class(gen_str)) }

        it { is_expected.to eq(name: nil, creation_strategy: :class_inheritance) }
      end

      context 'class-defined constant-assigned event class' do
        let(:event_const) { gen_str(only_letters: true).capitalize! }
        let(:event_class) { Object.const_get(event_const) }

        before { stub_const(event_const, Class.new(build_abstract_event_class(gen_str))) }

        it { is_expected.to eq(name: event_const, creation_strategy: :class_inheritance) }
      end
    end

    specify '#type_alias_stamp' do
      event_type  = gen_str
      event_class = build_event_class(event_type)
      signature   = described_class.new(event_class)

      expect(signature.type_alias_stamp).to eq(event_type)
    end

    specify '#delegator_stamp' do
      delegator_method_name = gen_symb
      event_class = build_event_class(gen_str) { default_delegator delegator_method_name }
      signature = described_class.new(event_class)

      expect(signature.delegator_stamp).to eq(delegator_method_name)
    end

    specify '#adapter_stamp' do
      sidekiq_ad_name, sidekiq_ad_obj = gen_str, double
      rabbit_ad_name,  rabbit_ad_obj  = gen_str, double
      redis_ad_name,   redis_ad_obj   = gen_str, double

      EvilEvents::Config.setup_adapters do |setup|
        setup.register(sidekiq_ad_name, sidekiq_ad_obj)
        setup.register(rabbit_ad_name,  rabbit_ad_obj)
        setup.register(redis_ad_name,   redis_ad_obj)
      end

      event_class = build_event_class(gen_str) { adapter sidekiq_ad_name }
      signature = described_class.new(event_class)
      expect(signature.adapter_stamp).to eq(sidekiq_ad_name => sidekiq_ad_obj)

      event_class = build_event_class(gen_str) { adapter rabbit_ad_name }
      signature = described_class.new(event_class)
      expect(signature.adapter_stamp).to eq(rabbit_ad_name => rabbit_ad_obj)

      event_class = build_event_class(gen_str) { adapter redis_ad_name }
      signature = described_class.new(event_class)
      expect(signature.adapter_stamp).to eq(redis_ad_name => redis_ad_obj)
    end

    describe '#== (#eql?)' do
      specify 'two signature objects of the same event class has different object ids' do
        event_class = build_event_class(gen_str)

        signature_a = described_class.new(event_class)
        signature_b = described_class.new(event_class)

        expect(signature_a.object_id).not_to eq(signature_b.object_id)
      end

      specify 'two signagure objects of the same event class are equal via == / eql?' do
        event_class = build_event_class(gen_str)

        signature_a = described_class.new(event_class)
        signature_b = described_class.new(event_class)

        expect(signature_a).to eql(signature_b) # eql?
        expect(signature_a).to eq(signature_b) # ==
      end

      specify 'signatures of similar (by structure) events are not equal' do
        structure_definition = proc do
          default_delegator :process_event

          payload :a
          payload :b, EvilEvents::Types::String

          metadata :a
          metadata :b, EvilEvents::Types::Integer

          adapter :memory_async
        end

        event_class         = build_event_class(gen_str, &structure_definition)
        another_event_class = build_event_class(gen_str, &structure_definition)

        signature_a = described_class.new(event_class)
        signature_b = described_class.new(another_event_class)

        expect(signature_a).not_to eql(signature_b) # eql?
        expect(signature_a).not_to eq(signature_b) # ==
      end
    end
  end
end
