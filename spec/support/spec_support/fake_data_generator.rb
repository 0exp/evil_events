# frozen_string_literal: true

module SpecSupport::FakeDataGenerator
  module_function

  def gen_integer(max = 1_000_000)
    rand(max)
  end

  def gen_float(max = 1_000_000.0)
    rand(max)
  end

  def gen_string(max_len = 100)
    SecureRandom.hex(max_len)
  end

  def gen_object
    Object.new
  end
end
