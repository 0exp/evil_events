# frozen_string_literal: true

# rubocop:disable Style/MethodMissingSuper, Lint/UnusedMethodArgument
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
# rubocop:enable Style/MethodMissingSuper, Lint/UnusedMethodArgument
