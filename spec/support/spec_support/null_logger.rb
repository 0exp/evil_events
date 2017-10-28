# frozen_string_literal: true

# rubocop:disable Style/MethodMissing, Lint/UnusedMethodArgument
module SpecSupport::NullLogger
  class << self
    def method_missing(method_name, *arguments, &block)
      self
    end

    def respond_to_missing?(method_name, *arguments, &block)
      true
    end
  end
end
# rubocop:enable Style/MethodMissing, Lint/UnusedMethodArgument
