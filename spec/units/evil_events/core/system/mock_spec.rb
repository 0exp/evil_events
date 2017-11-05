# frozen_string_literal: true

describe EvilEvents::Core::System::Mock do
  let(:mock) { described_class.new }

  shared_examples 'mocked dependency' do |dependency, excluded: [], only: []|
    specify "mocked #{dependency} interface" do
      # fetch all required method signatures
      method_names = only.any? ? only : dependency.instance_methods(false) - excluded

      original_method_signatures = method_names.map do |method_name|
        method_object = dependency.instance_method(method_name)
        { method: method_name, params: method_object.parameters }
      end

      # verify mocked method signatures
      original_method_signatures.each do |method_config|
        method_name   = method_config[:method]
        method_params = method_config[:params]

        # 1. mock object should respond to the original method
        expect(mock).to respond_to(method_name)

        mocked_method_object = mock.method(method_name)
        mocked_method_params = mocked_method_object.parameters

        # 2. mocked method signature equals to original method signature
        method_params.each do |param_definitions|
          expect(mocked_method_params).to include(param_definitions)
        end
      end
    end
  end

  # rubocop:disable Layout/AlignParameters
  it_behaves_like 'mocked dependency', EvilEvents::Core::System::EventBuilder.singleton_class
  it_behaves_like 'mocked dependency', EvilEvents::Core::System::Broadcaster,
                                       excluded: %i[event_emitter adapters_container]
  it_behaves_like 'mocked dependency', EvilEvents::Core::System::EventManager,
                                       excluded: [:manager_registry]
  it_behaves_like 'mocked dependency', EvilEvents::Core::System::TypeManager,
                                       excluded: [:converter]
  it_behaves_like 'mocked dependency', EvilEvents::Core::System,
                                       only: %i[broadcaster event_manager]

  # rubocop:enable Layout/AlignParameters
end
