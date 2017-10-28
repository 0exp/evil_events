# frozen_string_literal: true

describe EvilEvents::Shared::Logger do
  specify { expect(described_class).to be < ::Logger }
  specify { expect(described_class.new(STDOUT).level).to eq(::Logger::INFO) }
end
