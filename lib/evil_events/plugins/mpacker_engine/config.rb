# frozen_string_literal: true

# @api public
# @since 0.5.0
class EvilEvents::Core::Config
  setting :serializers do
    setting :msgpack do
      setting :mpacker do
        setting :configurator, ->(engine) {}
      end
    end
  end
end
