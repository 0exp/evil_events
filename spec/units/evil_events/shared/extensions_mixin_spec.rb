# frozen_string_literal: true

describe EvilEvents::Shared::ExtensionsMixin do
  specify { expect(described_class).to eq(Dry::Core::Extensions) }
end
