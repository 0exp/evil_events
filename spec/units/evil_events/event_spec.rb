# frozen_string_literal: true

describe EvilEvents::Event, :stub_event_system do
  include_context 'event system'

  describe '.[]' do
    it 'delegates the creation of the abstract event class to the event system' do
      event_type = gen_str

      expect(event_system).to(
        receive(:define_abstract_event_class).with(event_type).once
      )

      described_class[event_type]
    end

    it 'returns a result of the class creation process' do
      event_type = gen_str
      creation_result = double

      allow(event_system).to(
        receive(:define_abstract_event_class).and_return(creation_result)
      )

      expect(described_class[event_type]).to eq(creation_result)
    end

    it 'requires an event type alias only' do
      expect { described_class[] }.to raise_error(ArgumentError)
      expect { described_class[gen_str, gen_str] }.to raise_error(ArgumentError)
      expect { described_class[gen_str] }.not_to raise_error
    end
  end

  describe '.define' do
    it 'delegates the creation of the full event class to the event system' do
      event_type = gen_str
      event_definitions = proc {}

      expect(event_system).to(
        receive(:define_event_class).with(event_type).once do |&received_block|
          expect(received_block).to eq(event_definitions)
        end
      )

      described_class.define(event_type, &event_definitions)
    end

    it 'returns a result of the class creation process' do
      event_type = gen_str
      event_definitions = proc {}
      creation_result = double

      allow(event_system).to(
        receive(:define_event_class).and_return(creation_result)
      )

      expect(described_class.define(event_type, &event_definitions)).to eq(creation_result)
    end

    specify 'required attributes' do
      expect { described_class.define }.to raise_error(ArgumentError)
      expect { described_class.define(gen_str, double) }.to raise_error(ArgumentError)
      expect { described_class.define(gen_str) }.not_to raise_error
      expect { described_class.define(gen_str, &(proc {})) }.not_to raise_error
    end
  end
end
