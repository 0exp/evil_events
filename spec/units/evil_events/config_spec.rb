# frozen_string_literal: true

describe EvilEvents::Config, :stub_event_system do
  include_context 'event system'

  let(:config) { described_class }

  describe '.configure' do
    it 'yields configuration object' do
      original_configuration = nil
      system_config.configure { |config| original_configuration = config }

      public_configuration = nil
      config.configure { |config| public_configuration = config }

      expect(public_configuration).to eq(original_configuration)
    end
  end

  specify '.options' do
    expect(config.options).to eq(system_config.settings)
  end

  specify '.setup_types' do
    expect { |b| config.setup_types(&b) }.to yield_with_args(EvilEvents::Config::Types)
  end

  specify '.setup_adapters' do
    expect { |b| config.setup_adapters(&b) }.to yield_with_args(EvilEvents::Config::Adapters)
  end
end
