# frozen_string_literal: true

module SpecSupport::FakeDataGenerator
  module_function

  BOOL_VARIANTS   = [true, false].freeze
  INT_RANGE       = (0..100)
  FLOAT_RANGE     = (0.0..100.0)
  STR_LENGTH      = 10
  STR_LETTERS     = (('a'..'z').to_a | ('A'..'Z').to_a).freeze
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

  EVENT_ATTR_CONSTRAINTS = {
    primitive:       nil,
    strict:          '::Strict',
    coercible:       '::Coercible',
    form:            '::Form',
    json:            '::Json',
    maybe_strict:    '::Maybe::Strict',
    maybe_coercible: '::Maybe::Coercible'
  }.freeze

  EVENT_ATTR_TYPES = {
    primitive: %i[
      Any Nil Symbol Class True False Bool Int Float Decimal String Date DateTime Time Array Hash
    ].freeze,

    strict: %i[
      Nil Symbol Class True False Bool Int Float Decimal String Date DateTime Time Array Hash
    ].freeze,

    coercible: %i[
      String Int Float Decimal Array Hash
    ].freeze,

    form: %i[
      Nil Date DateTime Time True False Bool Int Float Decimal Array Hash
    ].freeze,

    json: %i[
      Nil Date DateTime Time Decimal Array Hash
    ].freeze,

    maybe_strict: %i[
      Class String Symbol True False Int Float Decimal Date DateTime Time Array Hash
    ].freeze,

    maybe_coercible: %i[
      String Int Float Decimal Array Hash
    ].freeze
  }.freeze

  def gen_int(range = INT_RANGE)
    rand(range)
  end

  def gen_float(range = FLOAT_RANGE)
    rand(range)
  end

  def gen_str(max_len: STR_LENGTH, only_letters: false)
    only_letters ? Array.new(STR_LENGTH) { STR_LETTERS.sample }.join : SecureRandom.hex(max_len)
  end

  def gen_obj
    Object.new
  end

  def gen_bool
    BOOL_VARIANTS.sample
  end

  def gen_symb(max_len: STR_LENGTH, only_letters: false)
    gen_str(max_len: max_len, only_letters: only_letters).to_sym
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

  def gen_event_attr_type(constraint = :primitive)
    type_name       = EVENT_ATTR_TYPES[constraint].sample
    type_constraint = EVENT_ATTR_CONSTRAINTS[constraint]
    type_const      = "EvilEvents::Shared::Types#{type_constraint}::#{type_name}"

    Object.const_get(type_const)
  end
end
