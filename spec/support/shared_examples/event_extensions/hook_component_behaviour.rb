# frozen_string_literal: true

shared_examples 'hook component behaviour' do |base_call_method: true|
  specify 'intiialization and state (#callable)' do
    callable = double
    hook     = described_class.new(callable)

    expect(hook.callable).to eq(callable)
  end

  if base_call_method
    specify 'invokation (#call)' do
      source   = double
      callable = double
      hook     = hook_class.new(callable)

      expect(callable).to receive(:call).with(source)

      hook.call(source)
    end
  end
end
