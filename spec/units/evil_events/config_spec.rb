# frozen_string_literal: true

describe EvilEvents::Config, :stub_event_system do
  include_context 'event system'

  describe '.configure' do
    it 'yields configuration object to provide a configuration API' do
      original_config_object = nil
      system_config.configure { |config| original_config_object = config }

      public_config_object = nil
      described_class.configure { |config| public_config_object = config }

      expect(public_config_object).to eq(original_config_object)
    end
  end

  specify '.options' do
    expect(described_class.options).to eq(system_config)
  end
end
