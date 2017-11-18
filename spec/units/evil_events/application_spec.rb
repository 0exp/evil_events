# frozen_string_literal: true

describe EvilEvents::Application, :stub_event_system do
  describe '.registered_events' do
    it 'returns a list of the all created event classes in { type => class } form' do
      expect(described_class.registered_events).to eq({})

      event_type  = gen_str
      event_class = EvilEvents::Event.define(event_type)

      expect(described_class.registered_events).to match(
        event_type => event_class
      )

      match_lost_alias = gen_str
      match_lost_event = Class.new(EvilEvents::Event[match_lost_alias])

      expect(described_class.registered_events).to match(
        match_lost_alias => match_lost_event,
        event_type       => event_class
      )
    end
  end

  it 'exceptional event initialization code doesnt affect event class list' do
    EvilEvents::Event.define(gen_str) { raise } rescue nil

    expect(described_class.registered_events).to eq({})

    event_class = EvilEvents::Event.define(gen_str)
    EvilEvents::Event.define(gen_str) { raise } rescue nil

    expect(described_class.registered_events).to match(
      event_class.type => event_class
    )

    another_event_class = EvilEvents::Event.define(gen_str)
    EvilEvents::Event.define(gen_str) { raise } rescue nil

    expect(described_class.registered_events).to match(
      event_class.type => event_class,
      another_event_class.type => another_event_class
    )
  end
end
