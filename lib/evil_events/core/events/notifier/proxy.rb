# frozen_string_literal: true

# @api private
# @since 0.3.0
class EvilEvents::Core::Events::Notifier::Proxy
  # @since 0.3.0
  extend Forwardable

  # @since 0.3.0
  def_delegators :notifier, :shutdown!, :restart!, :notify

  # @return [Mutex]
  #
  # @api private
  # @since 0.3.0
  attr_reader :initialization_mutex

  # @api private
  # @since 0.3.0
  def initialize
    @initialization_mutex = Mutex.new
  end

  # @return [Abstract, Sequential, Worker]
  #
  # @api private
  # @since 0.3.0
  def notifier
    initialization_mutex.synchronize do
      @notifier ||= EvilEvents::Core::Events::Notifier::Builder.build_notifier!
    end
  end
end
