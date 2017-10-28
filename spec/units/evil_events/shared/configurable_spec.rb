# frozen_string_literal: true

describe EvilEvents::Shared::Configurable do
  specify { expect(described_class).to eq(Dry::Configurable) }
end
