# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength
module SpecSupport::FakeDataGenerator
  module_function

  BOOL_VARIANTS   = [true, false].freeze
  INT_RANGE       = (0..100)
  FLOAT_RANGE     = (0.0..100.0)
  STR_LENGTH      = 10
  STR_LETTERS     = (('a'..'z').to_a | ('A'..'Z').to_a).freeze

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
    primitive:          nil,
    strict:             '::Strict',
    coercible:          '::Coercible',
    params:             '::Params',
    json:               '::JSON',
    maybe_strict:       '::Maybe::Strict',
    maybe_coercible:    '::Maybe::Coercible',
    optional_strict:    '::Optional::Strict',
    optional_coercible: '::Optional::Coercible'
  }.freeze

  EVENT_ATTR_TYPES = {
    primitive: %i[
      Decimal Nil True False Bool Time DateTime Integer
      Float String Array Hash Range Object Symbol Class Date Any
    ].freeze,

    strict: %i[
      Decimal Nil Symbol Class False True Bool Time
      Date Integer Float String Array Hash Range DateTime
    ].freeze,

    coercible: %i[
      Decimal Integer Float String Array Hash
    ].freeze,

    params: %i[
      Decimal Nil DateTime True False Bool
      Time Date Integer Float Array Hash
    ].freeze,

    json: %i[
      Decimal Nil DateTime Time Date Array Hash
    ].freeze,

    maybe_strict: %i[
      Decimal Symbol Class False True Time Date
      Integer Float String Array Hash Range DateTime
    ].freeze,

    maybe_coercible: %i[
      Decimal Integer Float String Array Hash
    ].freeze,

    optional_strict: %i[
      Decimal Symbol Class False True Time Date Integer
      Float String Array Hash Range DateTime
    ].freeze,

    optional_coercible: %i[
      Decimal Integer Float String Array Hash
    ].freeze
  }.freeze

  def gen_int(range = INT_RANGE)
    rand(range)
  end

  def gen_float(range = FLOAT_RANGE, round: 4)
    rand(range).round(round)
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
    Class.new
  end

  def gen_proc
    proc {}
  end

  def gen_lambda
    -> {}
  end

  def gen_all(except: nil)
    (FACTORY_METHODS - Array(except)).map { |generator| send(generator) }.shuffle!
  end

  def gen_event_attr_type(constraint = :primitive)
    type_name       = EVENT_ATTR_TYPES[constraint].sample
    type_constraint = EVENT_ATTR_CONSTRAINTS[constraint]
    type_const      = "EvilEvents::Shared::Types#{type_constraint}::#{type_name}"

    Object.const_get(type_const)
  end
end
# rubocop:enable Metrics/ModuleLength
