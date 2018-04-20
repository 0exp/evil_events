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
      config.notifier.type = :sequential
    end

    EvilEvents::Config.setup_adapters do |adapters|
      adapters.register(:sidekiq,    build_adapter_class.new)
      adapters.register(:redis,      build_adapter_class.new)
      adapters.register(:rabbit,     build_adapter_class.new)
      adapters.register(:background, build_adapter_class.new)
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

    DepositAntifrode = Class.new(EvilEvents::Event['deposit.antifrode']) do
      payload :amount, EvilEvents::Types::Int
      adapter :redis
    end

    DepositCanceled = Class.new(EvilEvents::Event['deposit.canceled']) do
      payload :reason, EvilEvents::Types::String
      adapter :redis
    end

    DepositCanceledImmidietly = Class.new(EvilEvents::Event['deposit.canceled.immidietly']) do
      payload :reason, EvilEvents::Types::String
      adapter :redis
    end

    # subscribe to events

    # via event type alias
    ElasticSearchStub.subscribe_to 'overwatch_released', delegator: :store
    # via event class
    ElasticSearchStub.subscribe_to MatchLost, delegator: :store
    # via conditional proc
    EventCounter.subscribe_to ->(event_type) { event_type == 'match_lost' }, delegator: :increase!
    # via event pattern
    EventCounter.subscribe_to /.*?overwatch.*?/i, delegator: :increase!
    # combination
    EventStoreStub.subscribe_to 'match_lost', OverwatchReleased, delegator: :push

    # subscribe to scope: deposit.rejected, deposit.rejected.immidietly
    EventCounter.subscribe_to_scope '*.canceled.#', delegator: :increase!

    # routing-key-based subscribtion

    # fails: unexistent event type alias
    expect do
      ElasticSearchStub.subscribe_to 'withdraw_processed', delegator: :complete
    end.to raise_error(EvilEvents::NonManagedEventClassError)

    # fails: unexistent event  class
    expect do
      EventStoreStub.subscribe_to Object
    end.to raise_error(EvilEvents::NonManagedEventClassError)

    # fails: unsupported attribute type
    expect { EventStoreStub.subscribe_to 123 }.to    raise_error(EvilEvents::ArgumentError)
    expect { ElasticSearchStub.subscribe_to 1.0 }.to raise_error(EvilEvents::ArgumentError)
    expect { EventCounter.subscribe_to :none }.to    raise_error(EvilEvents::ArgumentError)

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
      %r{
        \[EvilEvents:EventEmitted\(memory_sync\)\]:\s
        ID:\s[a-z0-9]{8}\-[a-z0-9]{4}\-[a-z0-9]{4}\-[a-z0-9]{4}\-[a-z0-9]{12}\s::\s
        TYPE:\smatch_lost\s::\s
        PAYLOAD:\s#{Regexp.escape(match_lost_attrs[:payload].to_s)}\s::\s
        METADATA:\s#{Regexp.escape(match_lost_attrs[:metadata].to_s)}
      }x
    )

    # check log output for the second event data
    expect(silent_output.string).to match(
      %r{
        \[EvilEvents:EventEmitted\(sidekiq\)\]:\s
        ID:\s[a-z0-9]{8}\-[a-z0-9]{4}\-[a-z0-9]{4}\-[a-z0-9]{4}\-[a-z0-9]{12}\s::\s
        TYPE:\soverwatch_released\s::\s
        PAYLOAD:\s#{Regexp.escape(overwatch_released_attrs[:payload].to_s)}\s::\s
        METADATA:\s#{Regexp.escape(overwatch_released_attrs[:metadata].to_s)}
      }x
    )

    # check log output for the notifier activity
    [ElasticSearchStub, EventStoreStub, EventCounter].each do |subscriber|
      expect(silent_output.string).to match(
        %r{
          \[EvilEvents:EventProcessed\(match_lost\)\]:\s
          EVENT_ID:\s[a-z0-9]{8}\-[a-z0-9]{4}\-[a-z0-9]{4}\-[a-z0-9]{4}\-[a-z0-9]{12}\s::\s
          STATUS:\ssuccessful\s::\s
          SUBSCRIBER:\s#{Regexp.escape(subscriber.to_s)}
        }x
      )
      expect(silent_output.string).to match(
        %r{
          \[EvilEvents:EventProcessed\(overwatch_released\)\]:\s
          EVENT_ID:\s[a-z0-9]{8}\-[a-z0-9]{4}\-[a-z0-9]{4}\-[a-z0-9]{4}\-[a-z0-9]{12}\s::\s
          STATUS:\ssuccessful\s::\s
          SUBSCRIBER:\s#{Regexp.escape(subscriber.to_s)}
        }x
      )
    end

    # BROADCASTING: Class method approach
    # check the third approach: class method approach
    # prepare event attributes for testability
    class_method_match_lost_attrs = {
      id:       SecureRandom.hex,
      payload:  { score: SecureRandom.hex },
      metadata: { host: SecureRandom.hex }
    }
    class_method_overwatch_released_attrs = {
      id:       SecureRandom.hex,
      payload:  { date: Time.now, price: Random.rand(100.0) },
      metadata: { timestamp: Random.rand(100) }
    }

    OverwatchReleased.emit!(**class_method_overwatch_released_attrs)
    MatchLost.emit!(**class_method_match_lost_attrs)

    # check state of subscriber
    expect(EventCounter.count).to eq(6)

    # check state of subscriber
    # check consistency
    expect(ElasticSearchStub.event_store).to contain_exactly(
      a_kind_of(OverwatchReleased),
      a_kind_of(MatchLost),
      a_kind_of(OverwatchReleased), # old event
      a_kind_of(MatchLost), # old event
      overwatch_event, # old event
      match_event # old event
    )

    # check attributes
    expect(ElasticSearchStub.event_store).to contain_exactly(
      have_attributes(type: 'overwatch_released', **class_method_overwatch_released_attrs),
      have_attributes(type: 'match_lost', **class_method_match_lost_attrs),
      have_attributes(type: 'overwatch_released', **overwatch_released_attrs), # old event
      have_attributes(type: 'match_lost', **match_lost_attrs), # old event
      overwatch_event, # old event
      match_event # old event
    )

    # check state of subscriber
    # check consistency
    expect(EventStoreStub.events).to contain_exactly(
      a_kind_of(OverwatchReleased),
      a_kind_of(MatchLost),
      a_kind_of(OverwatchReleased), # old event
      a_kind_of(MatchLost), # old event
      overwatch_event, # old event
      match_event # old event
    )

    # check attributes
    expect(EventStoreStub.events).to contain_exactly(
      have_attributes(type: 'overwatch_released', **class_method_overwatch_released_attrs),
      have_attributes(type: 'match_lost', **class_method_match_lost_attrs),
      have_attributes(type: 'overwatch_released', **overwatch_released_attrs), # new event
      have_attributes(type: 'match_lost', **match_lost_attrs), # new event
      overwatch_event, # old event
      match_event # old event
    )

    # check log output of the first event data
    expect(silent_output.string).to match(
      %r{
        \[EvilEvents:EventEmitted\(memory_sync\)\]:\s
        ID:\s#{Regexp.escape(class_method_match_lost_attrs[:id].to_s)}\s::\s
        TYPE:\smatch_lost\s::\s
        PAYLOAD:\s#{Regexp.escape(class_method_match_lost_attrs[:payload].to_s)}\s::\s
        METADATA:\s#{Regexp.escape(class_method_match_lost_attrs[:metadata].to_s)}
      }x
    )

    # check log output for the second event data
    expect(silent_output.string).to match(
      %r{
        \[EvilEvents:EventEmitted\(sidekiq\)\]:\s
        ID:\s#{Regexp.escape(class_method_overwatch_released_attrs[:id].to_s)}\s::\s
        TYPE:\soverwatch_released\s::\s
        PAYLOAD:\s#{Regexp.escape(class_method_overwatch_released_attrs[:payload].to_s)}\s::\s
        METADATA:\s#{Regexp.escape(class_method_overwatch_released_attrs[:metadata].to_s)}
      }x
    )

    # check log output for the notifier activity
    [ElasticSearchStub, EventStoreStub, EventCounter].each do |subscriber|
      expect(silent_output.string).to match(
        %r{
          \[EvilEvents:EventProcessed\(match_lost\)\]:\s
          EVENT_ID:\s#{Regexp.escape(class_method_match_lost_attrs[:id].to_s)}\s::\s
          STATUS:\ssuccessful\s::\s
          SUBSCRIBER:\s#{Regexp.escape(subscriber.to_s)}
        }x
      )
      expect(silent_output.string).to match(
        %r{
          \[EvilEvents:EventProcessed\(overwatch_released\)\]:\s
          EVENT_ID:\s#{Regexp.escape(class_method_overwatch_released_attrs[:id].to_s)}\s::\s
          STATUS:\ssuccessful\s::\s
          SUBSCRIBER:\s#{Regexp.escape(subscriber.to_s)}
        }x
      )
    end

    # BROADCASTING: broadcast via explicitly defined adapter
    EvilEvents::Emitter.emit(
      'match_lost', adapter: :background, **class_method_match_lost_attrs
    )
    EvilEvents::Emitter.emit(
      'overwatch_released', adapter: :rabbit, **class_method_overwatch_released_attrs
    )
    match_event.emit!(adapter: :rabbit)
    overwatch_event.emit!(adapter: :background)

    # check state of subscriber
    expect(EventCounter.count).to eq(10)

    # check state of subscriber
    # check consistency
    expect(EventStoreStub.events).to contain_exactly(
      a_kind_of(OverwatchReleased),
      a_kind_of(MatchLost),
      a_kind_of(OverwatchReleased),
      a_kind_of(MatchLost),
      a_kind_of(OverwatchReleased), # old event
      a_kind_of(MatchLost), # old event
      a_kind_of(OverwatchReleased), # old event
      a_kind_of(MatchLost), # old event
      overwatch_event, # old event
      match_event # old event
    )

    # check state of subscriber
    # check consistency
    expect(ElasticSearchStub.event_store).to contain_exactly(
      a_kind_of(OverwatchReleased),
      a_kind_of(MatchLost),
      a_kind_of(OverwatchReleased),
      a_kind_of(MatchLost),
      a_kind_of(OverwatchReleased), # old event
      a_kind_of(MatchLost), # old event
      a_kind_of(OverwatchReleased), # old event
      a_kind_of(MatchLost), # old event
      overwatch_event, # old event
      match_event # old event
    )

    # match_lost event log with explicitly defined adapter :background
    expect(silent_output.string).to match(
      %r{
        \[EvilEvents:EventEmitted\(background\)\]:\s
        ID:\s#{Regexp.escape(class_method_match_lost_attrs[:id].to_s)}\s::\s
        TYPE:\smatch_lost\s::\s
        PAYLOAD:\s#{Regexp.escape(class_method_match_lost_attrs[:payload].to_s)}\s::\s
        METADATA:\s#{Regexp.escape(class_method_match_lost_attrs[:metadata].to_s)}
      }x
    )
    # match_lost event log with explicitly defined adapter :rabbit
    expect(silent_output.string).to include(
      '[EvilEvents:EventEmitted(rabbit)]: ' \
      "ID: #{match_event.id} :: " \
      'TYPE: match_lost :: ' \
      "PAYLOAD: #{match_event.payload} :: " \
      "METADATA: #{match_event.metadata}"
    )

    # overwatch_released event log with explicitly defined adapter :rabbit
    expect(silent_output.string).to match(
      %r{
        \[EvilEvents:EventEmitted\(rabbit\)\]:\s
        ID:\s#{Regexp.escape(class_method_overwatch_released_attrs[:id].to_s)}\s::\s
        TYPE:\soverwatch_released\s::\s
        PAYLOAD:\s#{Regexp.escape(class_method_overwatch_released_attrs[:payload].to_s)}\s::\s
        METADATA:\s#{Regexp.escape(class_method_overwatch_released_attrs[:metadata].to_s)}
      }x
    )
    # match_lost event log with explicitly defined adapter :background
    expect(silent_output.string).to include(
      '[EvilEvents:EventEmitted(background)]: ' \
      "ID: #{overwatch_event.id} :: " \
      'TYPE: overwatch_released :: ' \
      "PAYLOAD: #{overwatch_event.payload} :: " \
      "METADATA: #{overwatch_event.metadata}"
    )

    # BROADCASTING: emit scoped events
    # subscribers: []
    DepositAntifrode.emit!(id: 100_500, payload: { amount: 5_571 })

    # subscribers: EventCounter
    DepositCanceled.emit!(id: 'secure123', payload: { reason: 'low_balance' })

    # subscribers: EventCounter
    DepositCanceledImmidietly.emit!(id: 'id555', payload: { reason: 'banned_user' })

    # changed
    # (deposit.rejected + deposit.rejected.immidietly)
    expect(EventCounter.count).to eq(12)

    # not changed
    expect(EventStoreStub.events).to contain_exactly(
      a_kind_of(OverwatchReleased), # old event
      a_kind_of(MatchLost), # old event
      a_kind_of(OverwatchReleased), # old event
      a_kind_of(MatchLost), # old event
      a_kind_of(OverwatchReleased), # old event
      a_kind_of(MatchLost), # old event
      a_kind_of(OverwatchReleased), # old event
      a_kind_of(MatchLost), # old event
      overwatch_event, # old event
      match_event # old event
    )

    # not changed
    expect(ElasticSearchStub.event_store).to contain_exactly(
      a_kind_of(OverwatchReleased), # old event
      a_kind_of(MatchLost), # old event
      a_kind_of(OverwatchReleased), # old event
      a_kind_of(MatchLost), # old event
      a_kind_of(OverwatchReleased), # old event
      a_kind_of(MatchLost), # old event
      a_kind_of(OverwatchReleased), # old event
      a_kind_of(MatchLost), # old event
      overwatch_event, # old event
      match_event # old event
    )
  end

  specify 'event callbacks' do
    # hook invocation results data
    hook_data = (1..20).to_a
    # hook invocation results collector
    hook_results = { after: [], before: [], on_error: [] }

    # create simple event class
    BonusReached = Class.new(EvilEvents::Event['bonus_reached']) do
      metadata :timestamp, EvilEvents::Types::Int

      # register corresponding hooks
      # rubocop:disable Metrics/LineLength
      before_emit ->(event)        { hook_results[:before]   << { event: event, indx: hook_data.shift } }
      before_emit ->(event)        { hook_results[:before]   << { event: event, indx: hook_data.shift } }
      after_emit  ->(event)        { hook_results[:after]    << { event: event, indx: hook_data.shift } }
      after_emit  ->(event)        { hook_results[:after]    << { event: event, indx: hook_data.shift } }
      on_error    ->(event, error) { hook_results[:on_error] << { event: event, indx: hook_data.shift, error: error } }
      # rubocop:enable Metrics/LineLength
    end

    # emit empty events => hooks working good! in corresponding order!
    BonusReached.new(metadata: { timestamp: 123_456 }).emit!
    # expected: 1,2 => before; 3,4 => after

    expect(hook_results).to match(
      before: [
        { event: an_instance_of(BonusReached), indx: 1 },
        { event: an_instance_of(BonusReached), indx: 2 }
      ],
      after: [
        { event: an_instance_of(BonusReached), indx: 3 },
        { event: an_instance_of(BonusReached), indx: 4 }
      ],
      on_error: []
    )

    failing_subscriber = Class.new do
      extend EvilEvents::SubscriberMixin
      def self.call(_event); raise ZeroDivisionError; end
    end
    failing_subscriber.subscribe_to BonusReached, delegator: :call

    # emit by event object
    event = BonusReached.new(metadata: { timestamp: 123_456 })
    # expected: 1,2 => before; 3,4 => after; 5,6 => before; 7 => on_error; 8,9 => after

    begin
      event.emit!
    rescue EvilEvents::FailingSubscribersError
      # do nothing, its a correct behaviour
    end

    # hooks still working correctly in corresponding order!
    expect(hook_results).to match(
      before: [
        { event: an_instance_of(BonusReached), indx: 1 }, # old
        { event: an_instance_of(BonusReached), indx: 2 }, # old
        { event: event, indx: 5 }, # new
        { event: event, indx: 6 }, # new
      ],
      after: [
        { event: an_instance_of(BonusReached), indx: 3 }, # old
        { event: an_instance_of(BonusReached), indx: 4 }, # old
        { event: event, indx: 8 }, # new
        { event: event, indx: 9 }, # new
      ],
      on_error: [
        { event: event, indx: 7, error: an_instance_of(ZeroDivisionError) }
      ] # new
    )
  end
end
