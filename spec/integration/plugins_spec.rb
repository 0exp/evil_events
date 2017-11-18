# frozen_string_literal: true

describe 'plugins ecosystem' do
  specify 'registered plugins' do
    expect(EvilEvents::Plugins.names).to contain_exactly('rails', 'elastic_search')
  end

  specify 'plugins installation' do
    expect { EvilEvents::Rails }.to raise_error(NameError)
    expect { EvilEvents::ElasticSearch }.to raise_error(NameError)

    # load concrete plugin
    EvilEvents::Plugins.load!(:rails)

    expect { EvilEvents::Rails }.not_to raise_error
    expect { EvilEvents::ElasticSearch }.to raise_error(NameError)

    # load all plugins
    EvilEvents::Plugins.load!

    expect { EvilEvents::Rails }.not_to raise_error
    expect { EvilEvents::ElasticSearch }.not_to raise_error
  end
end
