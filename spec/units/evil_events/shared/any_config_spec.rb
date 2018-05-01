# frozen_string_literal: true

describe EvilEvents::Shared::AnyConfig do
  specify 'empty configuration' do
    config_klass = Class.new(described_class)
    config = config_klass.new

    expect(config.to_hash).to eq({})
  end

  specify 'with settings' do
    config_klass = Class.new(described_class) do
      configure do
        setting :my_simple_setting, 55, reader: true

        setting :nested, reader: true do
          setting(:pre_processed, 50) { |value| value * 2 }
        end
      end
    end

    config = config_klass.new

    # dry-configurable: hash representation
    expect(config.to_h).to match(my_simple_setting: 55, nested: { pre_processed: 100 })
    expect(config.to_hash).to match(my_simple_setting: 55, nested: { pre_processed: 100 })
    # dry-configurable: config object
    expect(config.config.my_simple_setting).to eq(55)
    expect(config.config.nested.pre_processed).to eq(100)
    # dry-configurable: reader option
    expect(config.my_simple_setting).to eq(55)
    expect(config.nested.pre_processed).to eq(100)

    # dry-configurable: change config
    config.configure do |c|
      c.my_simple_setting = 66
      c.nested.pre_processed = 30
    end
    # dry-configurable: hash representation after changing
    expect(config.to_h).to match(my_simple_setting: 66, nested: { pre_processed: 60 })
    expect(config.to_hash).to match(my_simple_setting: 66, nested: { pre_processed: 60 })
    # dry-configurable: config object after changing
    expect(config.config.my_simple_setting).to eq(66)
    expect(config.config.nested.pre_processed).to eq(60)
    # dry-configurable: reader option after changing
    expect(config.my_simple_setting).to eq(66)
    expect(config.nested.pre_processed).to eq(60)
  end
end
