# frozen_string_literal: true

describe EvilEvents::Core::Events::Notifier::Worker::Job do
  let(:event) { build_event_class(gen_str).new }
  let(:subscriber) { build_event_subscriber }

  specify 'instantiation and options / attributes' do
    expect { described_class.new }.to raise_error(ArgumentError)
    expect { described_class.new(double) }.to raise_error(ArgumentError)
    expect { described_class.new(double, double, double) }.to raise_error(ArgumentError)
    expect { described_class.new(double, double) }.not_to raise_error

    job = described_class.new(event, subscriber)

    expect(job.event).to      eq(event)
    expect(job.subscriber).to eq(subscriber)
  end

  specify 'job invokation calls the subscriber notification process' do
    expect(subscriber).to receive(:notify).with(event).once
    described_class.new(event, subscriber).perform
  end
end
