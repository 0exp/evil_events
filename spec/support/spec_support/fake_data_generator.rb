# frozen_string_literal: true

module SpecSupport::FakeDataGenerator
  module_function

  BOOL_VARIANTS   = [true, false].freeze
  INT_RANGE       = (0..100)
  FLOAT_RANGE     = (0.0..100.0)
  STR_LENGTH      = 10
  CLASS_LIST      = [Object, Class, BasicObject].freeze
  FACTORY_METHODS = %i[
    gen_int
    gen_float
    gen_str
    gen_obj
    gen_bool
    gen_symb
    gen_class
    gen_proc
    gen_lambda
  ].freeze

  def gen_int(range = INT_RANGE)
    rand(range)
  end

  def gen_float(range = FLOAT_RANGE)
    rand(range)
  end

  def gen_str(max_len = STR_LENGTH)
    SecureRandom.hex(max_len)
  end

  def gen_obj
    Object.new
  end

  def gen_bool
    BOOL_VARIANTS.sample
  end

  def gen_symb(max_len = STR_LENGTH)
    gen_str(max_len).to_sym
  end

  def gen_seed
    send(FACTORY_METHODS.sample)
  end

  def gen_class
    CLASS_LIST.sample
  end

  def gen_proc
    proc {}
  end

  def gen_lambda
    -> {}
  end
end
