# frozen_string_literal: true

describe EvilEvents::Shared::CombinedContext do
  describe 'constructor and instance attributes details' do
    it 'instantiation process uses a context object and proc-object' do
      basic_context = double
      clojure       = proc {}
      expect { described_class.new(basic_context, clojure) }.not_to raise_error
    end

    it 'instantiation fails with error when clojure is not a proc object' do
      expect do
        described_class.new(double, double)
      end.to raise_error(described_class::NonProcClojureObjectError)

      expect { described_class.new(double, proc {}) }.not_to raise_error
    end

    it "remembers basic context, clojure and external clojure's context" do
      basic_context    = double
      clojure          = proc {}
      clojure_context  = eval('self', clojure.binding)

      combined_context = described_class.new(basic_context, clojure)

      expect(combined_context.__required_context__).to eq(basic_context)
      expect(combined_context.__outer_context__).to    eq(clojure_context)
      expect(combined_context.__clojure__).to          eq(clojure)
    end
  end

  describe 'evaluation process' do
    let(:context_object) do
      Class.new do
        def test_method_with_param(param)
          test_method
          param
        end

        def test_method
          10
        end

        def test_value
          30
        end
      end.new
    end

    describe '#evaluate' do
      specify 'evaluates the clojure in the context of the underlying instantiation object' do
        # we can check this moment by the non-errorable access to the instance variables
        # of combined context object OR by waiting for the call of our stubbed method

        # first variant: instance variables access
        clojure = proc { __clojure__ }
        combined_context = described_class.new(double, clojure)
        expect(combined_context.evaluate).to eq(clojure)

        # second variant: stubbed method invocation
        clojure = proc { stubbed_method }
        combined_context = described_class.new(double, clojure)
        expect(combined_context).to receive(:stubbed_method)
        combined_context.evaluate
      end

      specify "outer clojure's context is accessable from the evaluation process" do
        outer_context_value = double
        clojure = proc { outer_context_value }
        combined_context = described_class.new(double, clojure)
        expect(combined_context.evaluate).to eq(outer_context_value)
      end

      specify "required object's context is accessable from the evaluation process" do
        clojure = proc { test_method }
        combined_context = described_class.new(context_object, clojure)
        expect(combined_context.evaluate).to eq(context_object.test_method)

        clojure = proc { test_method_with_param(10) }
        combined_context = described_class.new(context_object, clojure)
        expect(combined_context.evaluate).to eq(context_object.test_method_with_param(10))
      end

      specify 'required context and clojure context can work together' do
        outer_context_value = 10
        # => 10 + 10 + 10 => 30
        clojure = proc { test_method + outer_context_value + test_method_with_param(10) }
        combined_context = described_class.new(context_object, clojure)
        expect(combined_context.evaluate).to eq(30)
      end

      specify 'context selection follows the outer => required => self order' do
        def test_method; 20; end # context_object.test_method => 10

        # outer > required ==> should return 20
        clojure = proc { test_method }
        combined_context = described_class.new(context_object, clojure)
        expect(combined_context.evaluate).to eq(20)
      end

      specify "fails when contexts dont responds to incapsulated clojure's methods" do
        clojure = proc { __super_mega_test_method__ }
        combined_context = described_class.new(double, clojure)
        expect { combined_context.evaluate }.to raise_error(NameError)
      end

      specify 'kernel methods are suppored correctly' do
        clojure = proc { proc {} } # proc is a kernel's mehtod
        combined_context = described_class.new(context_object, clojure)
        expect { combined_context.evaluate }.not_to raise_error
      end

      specify '#method works correctly and returns appropriate context method' do
        def test_method; 20; end
        clojure = proc {}
        combined_context = described_class.new(context_object, clojure)

        outer_method  = combined_context.method(:test_method)
        inner_method  = combined_context.method(:test_value)
        kernel_method = combined_context.method(:proc)

        expect(outer_method.call).to eq(20) # outer context, current spec
        expect(inner_method.call).to eq(30) # required context, context_object
        expect(kernel_method.receiver).to eq(::Kernel) # shared context, kernel method
      end
    end
  end
end
