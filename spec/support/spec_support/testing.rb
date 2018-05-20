# frozen_string_literal: true

module SpecSupport::Testing
  module_function

  def test_native_extensions?
    !!ENV['TEST_NATIVE_EXTENSIONS']
  end
end
