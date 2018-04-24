# frozen_string_literal: true

# @api public
# @since 0.4.0
class EvilEvents::Shared::AnyConfig
  class << self
    # @param configuration [Proc]
    # @return [Proc]
    #
    # @api public
    # @since 0.4.0
    def configure(&configuration)
      case
      when !block_given? && !instance_variable_defined?(:@setup)
        @setup = proc {}
      when block_given?
        @setup = configuration
      else
        @setup
      end
    end
  end

  # @api public
  # @since 0.4.0
  def initialize
    setup = self.class.configure

    @config = Module.new do
      extend Dry::Configurable
      instance_eval(&setup)
    end

    @config.configure { |conf| yield(conf) if block_given? }
  end

  private

  # @return [Dry::Configurable]
  #
  # @api private
  # @since 0.4.0
  attr_reader :config

  # @api private
  # @since 0.4.0
  def method_missing(method_name, *attributes, &block)
    return super unless config.respond_to?(method_name)
    config.public_send(method_name, *attributes, &block)
  end

  # @api private
  # @since 0.4.0
  def respond_to_missing?(method_name, include_private = false)
    config.respond_to?(method_name, include_private) || super
  end
end
