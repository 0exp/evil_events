# frozen_string_literal: true

describe EvilEvents::Shared::TypeConverter::TypeBuilder do
  describe 'public interface' do
    describe 'building steps (#append)' do
      context 'unsupported step' do
        it 'doesnt mutate type object' do
          builder = described_class.new

          builder.append(:default, :test)
          builder.append(:constructor, (->(value) {}))

          result_type = builder.result

          builder.append(gen_symb, gen_obj)
          expect(builder.result).to eq(result_type)

          builder.append(gen_symb, gen_obj)
          expect(builder.result).to eq(result_type)
        end
      end

      context ':default' do
        let(:step) { :default }

        it 'defines default value (by value/proc)' do
          # 1) define defaults
          default_value  = gen_str
          concrete_value = gen_obj

          builder = described_class.new
          builder.append(step, default_value)
          expect(builder.result[nil]).to eq(default_value)
          expect(builder.result[concrete_value]).to eq(concrete_value)

          # 2) define another defaults
          another_default_value  = gen_str
          another_cocnrete_value = gen_float

          builder = described_class.new
          builder.append(step, another_default_value)
          expect(builder.result[nil]).to eq(another_default_value)
          expect(builder.result[another_cocnrete_value]).to eq(another_cocnrete_value)

          # 3) try to use procs/lambdas
          lambda_value   = gen_str
          proc_value     = gen_float
          concrete_value = gen_obj

          builder = described_class.new
          builder.append(step, -> { lambda_value })
          expect(builder.result[nil]).to eq(lambda_value)
          expect(builder.result[concrete_value]).to eq(concrete_value)

          builder = described_class.new
          builder.append(step, proc { proc_value })
          expect(builder.result[nil]).to eq(proc_value)
          expect(builder.result[concrete_value]).to eq(concrete_value)
        end
      end

      context ':constructor' do
        let(:step) { :constructor }

        shared_examples 'type constructor definition' do |value:, constructor:|
          specify 'constructor works correctly' do
            expected_value = constructor.call(value)

            builder = described_class.new
            builder.append(step, constructor)
            expect(builder.result[value]).to eq(expected_value)
          end
        end

        it_behaves_like 'type constructor definition',
                        value: gen_obj,
                        constructor: proc { |value| value }

        it_behaves_like 'type constructor definition',
                        value: gen_obj,
                        constructor: ->(value) { value }

        it_behaves_like 'type constructor definition',
                        value: gen_float,
                        constructor: ->(value) { value * 2 }

        it_behaves_like 'type constructor definition',
                        value: gen_str,
                        constructor: proc { |value| "processed_#{value}" }
      end
    end

    describe '#result' do
      it 'returns the correct final object' do
        common_value  = gen_symb
        default_value = gen_float

        # correct initial type object
        builder = described_class.new
        type = builder.result
        expect(type).to eq(EvilEvents::Shared::Types::Any)
        expect(type[nil]).to eq(nil)
        expect(type[common_value]).to eq(common_value)

        # correct constructor
        builder.append(:constructor, ->(value) { value.to_s })
        type = builder.result
        expect(type[nil]).to eq('')
        expect(type[common_value]).to eq(common_value.to_s)

        # correct default value
        builder.append(:default, default_value)
        type = builder.result
        expect(type[]).to eq(default_value)
        expect(type[common_value]).to eq(common_value.to_s)
      end
    end
  end
end
