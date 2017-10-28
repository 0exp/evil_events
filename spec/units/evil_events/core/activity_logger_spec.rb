# frozen_string_literal: true

describe EvilEvents::Core::ActivityLogger do
  include_context 'event system'

  let(:activity_logger) { described_class }

  before do
    system_config.configure do |config|
      config.logger = ::Logger.new(StringIO.new)
    end
  end

  describe '#log' do
    it 'logs received activity (progname) and message via #logger and its log-level' do
      log_levels = [
        ::Logger::DEBUG,
        ::Logger::INFO,
        ::Logger::WARN,
        ::Logger::ERROR,
        ::Logger::FATAL,
        ::Logger::UNKNOWN
      ]

      log_levels.each do |expected_level|
        system_config.configure do |config|
          config.logger.level = expected_level
        end

        activity = SecureRandom.uuid
        message  = SecureRandom.uuid

        expected_progname = "[EvilEvents:#{activity}]"

        expect(system_config.logger).to(
          receive(:add).with(expected_level, message, expected_progname)
        )

        activity_logger.log(activity: activity, message: message)
      end
    end

    it 'activity and message attributes are optional' do
      activity = SecureRandom.uuid
      message  = SecureRandom.uuid

      expect { activity_logger.log }.not_to raise_error
      expect { activity_logger.log(activity: activity) }.not_to raise_error
      expect { activity_logger.log(message: message) }.not_to raise_error
      expect { activity_logger.log(activity: activity, message: message) }.not_to raise_error
    end

    it 'uses globally pre-configured logger object inside itself' do
      preconfigured_logger = system_config.logger

      level    = preconfigured_logger.level
      activity = 'RSpec'
      progname = "[EvilEvents:#{activity}]"
      message  = 'test'

      expect(preconfigured_logger).to receive(:add).with(level, message, progname)
      activity_logger.log(activity: activity, message: message)

      custom_preconfigured_logger = ::Logger.new(StringIO.new)
      system_config.configure do |config|
        config.logger = custom_preconfigured_logger
      end

      expect(custom_preconfigured_logger).to receive(:add).with(level, message, progname)
      activity_logger.log(activity: activity, message: message)
    end
  end
end
