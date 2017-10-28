# frozen_string_literal: true

describe EvilEvents::Shared::Structure do
  specify { expect(described_class).to be < Dry::Struct }
end
