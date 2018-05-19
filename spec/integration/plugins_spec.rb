# frozen_string_literal: true

describe 'plugins ecosystem' do
  specify 'registered plugins' do
    expect(EvilEvents::Plugins.names).to contain_exactly(:oj_engine, :ox_engine, :mpacker_engine)
  end

  # xspecify 'plugins installation' do
  #   expect { EvilEvents::RedisAdapter }.to raise_error(NameError)
  #   expect { EvilEvents::SidekiqAdapter }.to raise_error(NameError)

  #   # try to load non-registered plugin
  #   expect { EvilEvents::Plugins.load!(gen_seed) }.to raise_error(ArgumentError)

  #   # load concrete plugin
  #   EvilEvents::Plugins.load!(:redis_adapter)

  #   expect { EvilEvents::RedisAdapter }.not_to raise_error
  #   expect { EvilEvents::SidekiqAdapter }.to raise_error(NameError)

  #   # load all plugins
  #   EvilEvents::Plugins.load!

  #   expect { EvilEvents::RedisAdapter }.not_to raise_error
  #   expect { EvilEvents::SidekiqAdapter }.not_to raise_error
  # end
end
