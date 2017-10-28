# frozen_string_literal: true

describe EvilEvents::Shared::CombinedContext::Mixin do
  let(:evaluatable) do
    # rubocop:disable Style/MultilineBlockChain
    Class.new do
      def test_method
        'test_method'
      end
    end.tap do |klass|
      klass.include described_class
    end.new
    # rubocop:enable Style/MultilineBlockChain
  end

  describe 'evaluation process' do
    describe '#evaluate' do
      it 'evaluates proc with outer (proc) => required (self) => inner (wrapper) contexts' do
        outer_value = '_evaluated' # outer
        clojure = proc { test_method + outer_value } # inner (test method)
        expect(evaluatable.evaluate(&clojure)).to eq('test_method_evaluated') # all (eval)
      end

      it "fails when all contexts doesnt respond to incapsulated clojure's methods" do
        clojure = proc { super_mega_test }
        expect { evaluatable.evaluate(&clojure) }.to raise_error(NameError)
      end
    end
  end
end
