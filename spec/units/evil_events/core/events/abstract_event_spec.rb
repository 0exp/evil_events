# frozen_string_literal: true

describe EvilEvents::Core::Events::AbstractEvent do
  it_behaves_like 'adapter customizable interface' do
    let(:customizable) { Class.new(described_class) }
  end

  it_behaves_like 'manageable interface' do
    let(:manageable) { Class.new(described_class) }
  end

  it_behaves_like 'observable interface' do
    let(:observable) { Class.new(described_class) }
  end

  it_behaves_like 'serializable interface' do
    let(:serializable) { Class.new(described_class).new }
  end

  it_behaves_like 'payloadable interface' do
    let(:payloadable_abstraction) { described_class }
  end

  it_behaves_like 'metadata extendable interface' do
    let(:metadata_extendable_abstraction) { described_class }
  end

  it_behaves_like 'metadata extendable interface' do
    let(:metadata_extendable_abstraction) { described_class }
  end

  it_behaves_like 'emittable interface' do
    let(:emittable) { Class.new(described_class).new }
  end

  it_behaves_like 'class signature interface' do
    let(:event_class) { described_class }
  end

  it_behaves_like 'hookable interface' do
    let(:hookable) { Class.new(described_class) }
  end

  it_behaves_like 'type aliasing interface' do
    let(:pseudo_identifiable) { Class.new(described_class) }

    describe 'domain instance interface' do
      describe '#type' do
        it 'returns previously defined string alias of event type' do
          event_class = Class.new(pseudo_identifiable) { type 'test_specification_event' }
          expect(event_class.type).to eq('test_specification_event')
        end

        specify ':type attribute works correctly (with #type alias)' do
          event_class = Class.new(pseudo_identifiable) do
            type 'non_misconfigurated_event'
            payload :type
          end

          event_instance = event_class.new(payload: { type: 'kek' })

          expect(event_instance.type).to eq('non_misconfigurated_event')
          expect(event_instance.payload[:type]).to eq('kek')
        end
      end
    end
  end

  # TODO: dry with <payload entity component>
  it_behaves_like 'metadata entity component' do
    let(:metadata_abstraction) { described_class }

    describe 'domain instance interface' do
      describe '#metadata' do
        let(:event_instance) do
          Class.new(metadata_abstraction) do
            metadata :sum,  EvilEvents::Types::Strict::Int.default(proc { 123_456 })
            metadata :sys,  EvilEvents::Types::String
            metadata :type, EvilEvents::Types::Strict::Symbol.default(proc { :lols })
          end.new(metadata: { sys: 'lol' })
        end

        it 'metadata can be received via #metadata method in a hash format' do
          expect(event_instance.metadata).to match(sum: 123_456, sys: 'lol', type: :lols)
        end

        it 'returned hash object doesnt affects any event attributes or #metadata result' do
          expect(event_instance.metadata.object_id).not_to eq(event_instance.metadata.object_id)
        end
      end
    end
  end

  # TODO: dry with <metadata entity component>
  it_behaves_like 'payload entity component' do
    let(:payload_abstraction) { described_class }

    describe 'domain instance interface' do
      describe '#payload' do
        let(:event_instance) do
          Class.new(payload_abstraction) do
            payload :sum,  EvilEvents::Types::Strict::Int.default(proc { 123_456 })
            payload :sys,  EvilEvents::Types::String
            payload :type, EvilEvents::Types::Strict::Symbol.default(proc { :lols })
          end.new(payload: { sys: 'lol' })
        end

        it 'all defined attributes can be received via #payload method in a hash format' do
          expect(event_instance.payload).to match(sum: 123_456, sys: 'lol', type: :lols)
        end

        it 'returned hash object doesnt affects any event attributes or #payload result' do
          expect(event_instance.payload.object_id).not_to eq(event_instance.payload.object_id)
        end
      end
    end
  end

  describe 'instance attributes' do
    describe '#id' do
      specify 'each event instance has own #id' do
        uniq_events = Array.new(100) { Class.new(described_class).new }.tap do |events|
          events.uniq!(&:id)
        end

        expect(uniq_events.size).to eq(100)
      end
    end
  end
end
