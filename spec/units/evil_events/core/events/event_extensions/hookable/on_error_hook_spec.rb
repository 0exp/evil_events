# frozen_string_literal: true

describe EvilEvents::Core::Events::EventExtensions::Hookable::OnErrorHook do
  it_behaves_like 'hook component behaviour', base_call_method: false do
    let(:hook_class) { described_class }
  end

  specify 'invokation (#call)' do
    source   = double
    error    = double
    callable = double
    hook     = described_class.new(callable)

    expect(callable).to receive(:call).with(source, error)

    hook.call(source, error)
  end
end
