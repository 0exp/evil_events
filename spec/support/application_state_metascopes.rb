# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:example) do
    EvilEvents::Plugins.enable_stubs!
    EvilEvents::Core::Bootstrap.enable_stubs!
    EvilEvents::Core::Events::Serializers.enable_stubs!
    EvilEvents::Core::Bootstrap.stub(:config, EvilEvents::Core::Config.build_stub)
  end

  config.after(:example) do
    EvilEvents::Plugins.unstub
    EvilEvents::Core::Bootstrap.unstub
    EvilEvents::Core::Events::Serializers.unstub
  end

  config.before(:example, :mock_event_system) do
    EvilEvents::Core::Bootstrap.stub(:event_system, EvilEvents::Core::System.build_mock)
  end

  config.before(:example, :stub_event_system) do
    EvilEvents::Core::Bootstrap.stub(:event_system, EvilEvents::Core::System.build_stub)
  end

  config.before(:example, :null_logger) do
    EvilEvents::Core::Bootstrap[:config].configure do |conf|
      conf.logger = SpecSupport::NullLogger
    end
  end
end
