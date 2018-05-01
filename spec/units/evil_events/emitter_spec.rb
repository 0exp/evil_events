# frozen_string_literal: true

describe EvilEvents::Emitter, :stub_event_system do
  include_context 'event system'

  describe '.emit' do
    it 'receives event attributes and delegates event handling process to the event system' do
      event_type = 'suite_event'

      event_attributes = {
        id:       gen_int,
        payload:  { a: gen_int },
        metadata: { b: gen_str },
        adapter:  gen_symb
      }

      expect(event_system).to(
        receive(:raw_emit).with(event_type, hash_including(event_attributes))
      )

      described_class.emit(event_type, **event_attributes)
    end
  end
end
