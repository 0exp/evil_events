# frozen_string_literal: true

describe EvilEvents::Core::Events::Notifier::Logging do
  it_behaves_like 'notifier logging interface' do
    let(:loggable) { Class.new.tap { |klass| klass.extend described_class } }
  end
end
