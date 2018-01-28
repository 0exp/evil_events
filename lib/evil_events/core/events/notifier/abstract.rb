# frozen_string_literal: true

# @api private
# @since 0.3.0
class EvilEvents::Core::Events::Notifier::Abstract
  # @param options [Hash]
  #
  # @api private
  # @since 0.3.0
  def initialize(**options); end

  # @param event [EvilEvents::Core::Events::AbstractEvent]
  # @param subscriber [EvilEvents::Core::Events::Subscriber]
  #
  # @api private
  # @since 0.3.0
  def notify!(event, subscriber); end
end
