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

    describe '.emit!' do
      it 'creates new event invokes emition process on the new created event' do
        expected_id = gen_int

        expected_payload = {
          gen_symb(only_letters: true) => gen_int,
          gen_symb(only_letters: true) => gen_str
        }

        expected_metadata = {
          gen_symb(only_letters: true) => gen_str,
          gen_symb(only_letters: true) => gen_int
        }

        emittable.class.instance_eval do |klass|
          expected_payload.each_key do |payload_key|
            klass.payload payload_key
          end

          expected_metadata.each_key do |metadata_key|
            klass.metadata metadata_key
          end
        end

        expect(EvilEvents::Core::Bootstrap[:event_system]).to(
          receive(:emit).with(
            have_attributes(
              id:       expected_id,
              payload:  expected_payload,
              metadata: expected_metadata
            )
          ).once
        )

        emittable.class.emit!(
          id:       expected_id,
          payload:  expected_payload,
          metadata: expected_metadata
        )
      end
    end
  end
end
