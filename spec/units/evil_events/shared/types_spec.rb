# frozen_string_literal: true

describe EvilEvents::Shared::Types do
  specify do
    expect(described_class.constants).to contain_exactly(
      # dry-types constants
      :String,
      :Integer,
      :Float,
      :Decimal,
      :Array,
      :Hash,
      :Nil,
      :Symbol,
      :Class,
      :True,
      :False,
      :Date,
      :DateTime,
      :Time,
      :Strict,
      :Coercible,
      :Optional,
      :Bool,
      :Any,
      :Object,
      :Params,
      :JSON,
      :Maybe,
      :Range
    )
  end
end
