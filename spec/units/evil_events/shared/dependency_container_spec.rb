# frozen_string_literal: true

describe EvilEvents::Shared::DependencyContainer do
  specify { expect(described_class).to eq(Dry::Container) }
end
