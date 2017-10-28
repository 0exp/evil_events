# frozen_string_literal: true

module SpecSupport::DumbEventSerializer
  SERIALIZATION_RESULT   = :dumb_serialization_result
  DESERIALIZATION_RESULT = :dumb_deserialization_result

  class << self
    def serialize(_event)
      SERIALIZATION_RESULT
    end

    def deserialize(_event)
      DESERIALIZATION_RESULT
    end
  end
end
