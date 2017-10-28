# frozen_string_literal: true

describe EvilEvents::Shared::DelegatorResolver do
  describe 'instantiation' do
    it 'accepts proc objects only' do
      expect { described_class.new(-> {}) }.not_to raise_error
      expect { described_class.new(proc {}) }.not_to raise_error

      clojure = double
      expect { described_class.new(clojure) }.to raise_error(
        described_class::InvalidProcAttributeError
      )

      allow(clojure).to receive(:call)
      expect { described_class.new(clojure) }.to raise_error(
        described_class::InvalidProcAttributeError
      )
    end
  end

  describe 'shared interface' do
    describe '#method_name_resolver' do
      it 'returns the proc object which accepted on an instantiation process' do
        clojure  = proc {}
        resolver = described_class.new(clojure)

        expect(resolver.method_name_resolver).to eq(clojure)
      end
    end

    describe '#delegator' do
      it 'returns the calculated delegation method based on proc-ivar calculation' do
        test_clojure_1 = proc { :test_clojure_1 }
        test_clojure_2 = proc { :test_clojure_2 }

        resolver = described_class.new(test_clojure_1)
        expect(resolver.delegator).to eq(:test_clojure_1)

        resolver = described_class.new(test_clojure_2)
        expect(resolver.delegator).to eq(:test_clojure_2)
      end

      it 'memoizes the calculated result value' do
        local_value     = 1
        test_clojure    = proc { local_value += 1 }
        resolver        = described_class.new(test_clojure)
        memoized_result = resolver.delegator

        expect(resolver.delegator).to eq(memoized_result)
      end
    end
  end
end
