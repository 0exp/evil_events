# frozen_string_literal: true

shared_examples 'emittable interface' do
  describe 'event invocation behaviour', :mock_event_system do
    describe '#emit!' do
      it 'delegates event handling process to the event system' do
        expect(EvilEvents::Core::Bootstrap[:event_system]).to(
          receive(:emit).with(emittable).once
        )

        emittable.emit!
      end
    end
  end
end
