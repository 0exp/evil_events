# frozen_string_literal: true

describe 'plugins ecosystem' do
  specify 'registered plugins' do
    expect(EvilEvents::Plugins.names).to contain_exactly(
      :oj_engine,
      :ox_engine,
      :mpacker_engine
    )
  end
end
