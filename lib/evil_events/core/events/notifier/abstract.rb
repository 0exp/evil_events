# frozen_string_literal: true

# @api private
# @since 0.3.0
class EvilEvents::Core::Events::Notifier::Abstract
  # @param options [Hash]
  #
  # @api private
  # @since 0.3.0
  def initialize(**options); end

  # @param manager [EvilEvents::Core::Events::Manager]
  # @param event [EvilEvents::Core::Events::AbstractEvent]
  #
  # @api private
  # @since 0.3.0
  def notify(manager, event); end

  # @api private
  # @since 0.3.0
  def restart!; end

  # @api private
  # @since 0.3.0
  def shutdown!; end
end
