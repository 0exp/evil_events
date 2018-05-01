# frozen_string_literal: true

module EvilEvents::Core::Events
  # @api private
  # @since 0.1.0
  class Serializers
    # @since 0.4.0
    include EvilEvents::Shared::DependencyContainer::Mixin

    # @return void
    #
    # @api private
    # @since 0.4.0
    def register_core_serializers!
      register(:json, memoize: true)    { JSON::Factory.new.create! }
      register(:hash, memoize: true)    { Hash::Factory.new.create! }
      register(:msgpack, memoize: true) { MessagePack::Factory.new.create! }
      register(:xml, memoize: true)     { XML::Factory.new.create! }
    end
  end
end
