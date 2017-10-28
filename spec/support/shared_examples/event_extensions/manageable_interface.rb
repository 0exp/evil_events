# frozen_string_literal: true

shared_examples 'manageable interface' do
  describe 'manageable behavior', :mock_event_system do
    describe 'event class registration' do
      describe '.manage!' do
        it 'registers the current event class via delegation this process to the event system' do
          allow(EvilEvents::Core::Bootstrap[:event_system]).to receive(:register_event_class)

          manageable.manage!

          expect(EvilEvents::Core::Bootstrap[:event_system]).to(
            have_received(:register_event_class).with(manageable)
          )
        end
      end
    end
  end
end
