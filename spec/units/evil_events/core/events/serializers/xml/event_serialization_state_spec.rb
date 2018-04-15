# frozen_string_literal: true

describe EvilEvents::Core::Events::Serializers::XML::EventSerializationState, :stub_event_system do
  specify 'mapped event attributes' do
    event = build_event_class('test_event') do
      payload :a
      payload :b
      payload :c

      metadata :d
      metadata :e
      metadata :f
    end.new(
      payload:  { a: gen_int, b: gen_str,  c: gen_symb  },
      metadata: { d: gen_str, e: gen_symb, f: gen_float }
    )

    state_map = described_class.new(event)

    expect(state_map.instance_variables).to contain_exactly(:@id, :@type, :@metadata, :@payload)

    expect(state_map.id).to       eq(event.id)
    expect(state_map.type).to     eq(event.type)
    expect(state_map.metadata).to match(event.metadata)
    expect(state_map.payload).to  match(event.payload)
  end
end
