# frozen_string_literal: true

module SpecSupport::DispatchingAdapterFactories
  module_function

  def build_adapter_class
    Class.new do
      include EvilEvents::Core::Broadcasting::Dispatcher::Mixin

      def call(event)
        dispatch(event)
      end

      yield(self) if block_given?
    end
  end
end
