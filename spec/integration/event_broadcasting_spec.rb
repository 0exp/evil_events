# frozen_string_literal: true

describe 'Event Broadcasting', :stub_event_system do
  let(:silent_output) { StringIO.new }
  let(:silent_logger) { Logger.new(silent_output) }

  let(:elastic_search) do
    Class.new do
      include EvilEvents::SubscriberMixin

      attr_reader :event_store

      def initialize
        @event_store = []
      end

      def store(event)
        event_store << event
      end
    end.new
  end

  let(:event_store) do
    Class.new do
      include EvilEvents::SubscriberMixin

      attr_reader :events

      def initialize
        @events = []
      end

      def push(event)
        events << event
      end
    end.new
  end

  let(:event_counter) do
    Class.new do
      include EvilEvents::SubscriberMixin

      def initialize
        @event_counter = Concurrent::Atom.new(0)
      end

      def increase!(_event)
        event_counter.swap { |count| count + 1 }
      end

      def count
        event_counter.value
      end

      private

      attr_reader :event_counter
    end.new
  end

  before do
    stub_const('::ElasticSearchStub', elastic_search)
    stub_const('::EventStoreStub', event_store)
    stub_const('::EventCounter', event_counter)

    EvilEvents::Config.configure do |config|
      config.logger = silent_logger
    end

    EvilEvents::Config.setup_adapters do |adapters|
      adapters.register(:sidekiq, build_adapter_class.new)
    end
  end

  specify 'event broadcasting' do
    # create simple event class
    OverwatchReleased = Class.new(EvilEvents::Event['overwatch_released']) do
      payload :date,  EvilEvents::Types::DateTime
      payload :price, EvilEvents::Types::Float

      metadata :timestamp, EvilEvents::Types::Int

      adapter :sidekiq
    end

    # create another simple event class
    MatchLost = Class.new(EvilEvents::Event['match_lost']) do
      payload :score, EvilEvents::Types::String

      metadata :host, EvilEvents::Types::String

      adapter :memory_sync
    end

    # subscribe to events
    ElasticSearchStub.subscribe_to 'overwatch_released', MatchLost, delegator: :store
    EventStoreStub.subscribe_to    'match_lost', OverwatchReleased, delegator: :push

    EventCounter.subscribe_to(
      ->(event_type) { event_type == 'match_lost' },
      /.*?overwatch.*?/i,
      delegator: :increase!
    )

    # check the first approach: event objects
    # create event objects
    match_event = MatchLost.new(
      payload:  { score: SecureRandom.hex },
      metadata: { host:  SecureRandom.hex }
    )
    overwatch_event = OverwatchReleased.new(
      payload:  { date: Time.now, price: Random.rand(100.0) },
      metadata: { timestamp: Random.rand(100) }
    )

    # BROADCASTING: objects approach
    match_event.emit!
    overwatch_event.emit!

    # check state of subscribers
    expect(ElasticSearchStub.event_store).to contain_exactly(match_event, overwatch_event)
    expect(EventStoreStub.events).to contain_exactly(match_event, overwatch_event)
    expect(EventCounter.count).to eq(2)

    # check log output of the first event data
    expect(silent_output.string).to include(
      '[EvilEvents:EventEmitted(memory_sync)]: ' \
      "ID: #{match_event.id} :: " \
      'TYPE: match_lost :: ' \
      "PAYLOAD: #{match_event.payload} :: " \
      "METADATA: #{match_event.metadata}"
    )

    # check log output for the second event data
    expect(silent_output.string).to include(
      '[EvilEvents:EventEmitted(sidekiq)]: ' \
      "ID: #{overwatch_event.id} :: " \
      'TYPE: overwatch_released :: ' \
      "PAYLOAD: #{overwatch_event.payload} :: " \
      "METADATA: #{overwatch_event.metadata}"
    )

    # check log output for the notifier activity
    [match_event, overwatch_event].each do |published_event|
      expect(silent_output.string).to include(
        "[EvilEvents:EventProcessed(#{published_event.type})]: " \
        "EVENT_ID: #{published_event.id} :: " \
        'STATUS: successful :: ' \
        "SUBSCRIBER: #{ElasticSearchStub}"
      )

      expect(silent_output.string).to include(
        "[EvilEvents:EventProcessed(#{published_event.type})]: " \
        "EVENT_ID: #{published_event.id} :: " \
        'STATUS: successful :: ' \
        "SUBSCRIBER: #{EventStoreStub}"
      )
    end

    # check the second approach: event attributes
    # prepare event attributes for testability
    match_lost_attrs = {
      payload:  { score: SecureRandom.hex },
      metadata: { host:  SecureRandom.hex }
    }
    overwatch_released_attrs = {
      payload:  { date: Time.now, price: Random.rand(100.0) },
      metadata: { timestamp: Random.rand(100) }
    }

    # BROADCASTING: attributes aproach
    EvilEvents::Emitter.emit('match_lost', **match_lost_attrs)
    EvilEvents::Emitter.emit('overwatch_released', **overwatch_released_attrs)

    # check state of subscriber
    expect(EventCounter.count).to eq(4)

    # check state of subscriber
    # check consistency
    expect(ElasticSearchStub.event_store).to contain_exactly(
      a_kind_of(OverwatchReleased), # new event
      a_kind_of(MatchLost), # new event
      overwatch_event, # old event
      match_event # old event
    )
    # check attributes
    expect(ElasticSearchStub.event_store).to contain_exactly(
      have_attributes(type: 'overwatch_released', **overwatch_released_attrs), # new event
      have_attributes(type: 'match_lost', **match_lost_attrs), # new event
      overwatch_event, # old event
      match_event # old event
    )

    # check state of subscriber
    # check consistency
    expect(EventStoreStub.events).to contain_exactly(
      a_kind_of(OverwatchReleased), # new event
      a_kind_of(MatchLost), # new event
      overwatch_event, # old event
      match_event # old event
    )
    # check attributes
    expect(EventStoreStub.events).to contain_exactly(
      have_attributes(type: 'overwatch_released', **overwatch_released_attrs), # new event
      have_attributes(type: 'match_lost', **match_lost_attrs), # new event
      overwatch_event, # old event
      match_event # old event
    )

    # check log output of the first event data
    expect(silent_output.string).to match(
      Regexp.union(
        /\[EvilEvents:EventEmitted\(memory_sync\)\]\s/,
        /ID:\s[a-z0-9\-]\s::\s/,
        /TYPE:\smatch_lost\s::\s/,
        /PAYLOAD:\s#{match_lost_attrs[:payload]}\s::\s/,
        /METADATA:\s#{match_lost_attrs[:metadata]}/
      )
    )

    # check log output for the second event data
    expect(silent_output.string).to match(
      Regexp.union(
        /\[EvilEvents:EventEmitted\(sidekiq\)\]\s/,
        /ID:\s[a-z0-9\-]\s::\s/,
        /TYPE:\soverwatch_released\s::\s/,
        /PAYLOAD:\s#{overwatch_released_attrs[:payload]}\s::\s/,
        /METADATA:\s#{overwatch_released_attrs[:metadata]}/
      )
    )

    # check log output for the notifier activity
    [ElasticSearchStub, EventStoreStub, EventCounter].each do |subscriber|
      expect(silent_output.string).to match(
        Regexp.union(
          /\[EvilEvents:EventProcessed\(match_lost\)\s/,
          /EVENT_ID:\s[a-z0-9\-]\s::\s/,
          /STATUS:\ssuccessful\s::\s/,
          /SUBSCRIBER:\s#{subscriber.to_s}/
        )
      )
      expect(silent_output.string).to match(
        Regexp.union(
          /\[EvilEvents:EventProcessed\(overwatch_released\)\s/,
          /EVENT_ID:\s[a-z0-9\-]\s::\s/,
          /STATUS:\ssuccessful\s::\s/,
          /SUBSCRIBER:\s#{subscriber.to_s}/
        )
      )
    end
  end
end
