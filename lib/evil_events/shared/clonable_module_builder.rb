# frozen_string_literal: true

module EvilEvents::Shared
  # @api public
  # @since 0.1.0
  module ClonableModuleBuilder
    class << self
      # @param module_definitions [Proc]
      # @return [Module]
      #
      # @since 0.1.0
      def build(&module_definitions)
        Module.new do
          class_eval(&module_definitions) if block_given?

          singleton_class.instance_eval do
            define_method :module_clone do
              ClonableModuleBuilder.build(&module_definitions)
            end
          end
        end
      end
    end
  end
end
