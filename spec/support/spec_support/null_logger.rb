# frozen_string_literal: true

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
