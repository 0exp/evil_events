# frozen_string_literal: true

shared_examples 'event dispatching interface' do
  describe 'event dispatching behaviour' do
    describe '#dispatch' do
      context 'when we tries to dispatch a system-managed event object' do
        it 'delegates event handling to the appropriate event manager' do
          event_system = EvilEvents::Core::Bootstrap[:event_system]

          first_event  = EvilEvents::Event.define('first_event').new
          second_event = EvilEvents::Event.define('second_event').new
          third_event  = EvilEvents::Event.define('third_event').new

          first_manager  = event_system.manager_of_event(first_event)
          second_manager = event_system.manager_of_event(second_event)
          third_manager  = event_system.manager_of_event(third_event)

          expect(first_manager).to receive(:notify).with(first_event).once
          dispatcher.dispatch(first_event)

          expect(second_manager).to receive(:notify).with(second_event).once
          dispatcher.dispatch(second_event)

          expect(third_manager).to receive(:notify).with(third_event).once
          dispatcher.dispatch(third_event)
        end
      end

      context 'when we tries to dispatch a system-non-managed event object' do
        subject(:dispatch) { dispatcher.dispatch double }

        it 'fails with non-managed event class error' do
          expect { dispatch }.to raise_error(EvilEvents::NonManagedEventClassError)
        end
      end
    end
  end
end
