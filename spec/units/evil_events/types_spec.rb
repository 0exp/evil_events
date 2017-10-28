# frozen_string_literal: true

describe EvilEvents::Types do
  specify do
    expect(described_class).to eq(EvilEvents::Shared::Types)
  end
end
