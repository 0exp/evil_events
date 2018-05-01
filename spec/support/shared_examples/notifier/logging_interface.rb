# frozen_string_literal: true

shared_examples 'notifier logging interface' do
  describe 'logging interface logic', :stub_event_system do
    let(:event)         { build_event_class('test_event').new }
    let(:subscriber)    { build_event_subscriber }
    let(:silent_output) { StringIO.new }
    let(:silent_logger) { ::Logger.new(silent_output) }

    before do
      EvilEvents::Core::Bootstrap[:config].configure do |config|
        config.logger = silent_logger
      end
    end

    specify '#log_failure' do
      loggable.log_failure(event, subscriber)

      expect(silent_output.string).to include(
        "[EvilEvents:EventProcessed(#{event.type})]: " \
        "EVENT_ID: #{event.id} :: " \
        'STATUS: failed :: ' \
        "SUBSCRIBER: #{subscriber.source_object}"
      )
    end

    specify '#log_success' do
      loggable.log_success(event, subscriber)

      expect(silent_output.string).to include(
        "[EvilEvents:EventProcessed(#{event.type})]: " \
        "EVENT_ID: #{event.id} :: " \
        'STATUS: successful :: ' \
        "SUBSCRIBER: #{subscriber.source_object}"
      )
    end
  end
end
