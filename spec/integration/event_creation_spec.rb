# frozen_string_literal: true

describe 'Event Creation', :stub_event_system do
  let(:elastic_search) do
    Class.new do
      attr_reader :event_store

      def initialize
        @event_store = []
      end

      def store(event)
        event_store << event
      end
    end.new
  end

  let(:event_database) do
    Class.new do
      attr_reader :events

      def initialize
        @events = []
      end

      def push(event)
        events << event
      end
    end.new
  end

  let(:registrator) do
    Class.new do
      class << self
        def process_event(event); end
      end
    end.new
  end

  before do
    stub_const('::ElasticSearchStub', elastic_search)
    stub_const('::EventDatabaseStub', event_database)
    stub_const('::RegistratorStub',   registrator)

    EvilEvents::Config.setup_types do |types|
      types.define_converter(:uuid) do |value|
        value.gsub(/[0-9]/, '*')
      end

      types.define_converter(:comment) do |value|
        value.to_s.strip
      end

      types.define_converter(:bigdecimal) do |value|
        BigDecimal(value)
      end

      types.define_converter(:timestamp) do |value|
        Time.parse(value)
      end
    end

    EvilEvents::Config.setup_adapters do |adapters|
      adapters.register(:sidekiq, build_adapter_class)
      adapters.register(:faktory, build_adapter_class)
    end
  end

  describe 'class creation' do
    specify 'modern block definition' do
      expect do
        # event type alias ('user_registered')
        EvilEvents::Event.define('user_registered') do
          # method that will be invoked on observers by default (delegator: option)
          default_delegator :process_event

          # emition hooks
          before_emit ->(event) {}
          after_emit  ->(event) {}
          on_error    ->(event, error) {}

          # payload keys
          payload :user_id,  EvilEvents::Types::Strict::Integer
          payload :utm_link, EvilEvents::Types::Strict::String
          payload :comment,  :comment

          # metadata keys
          metadata :timestamp # Dry::Types
          metadata :secure_id, :uuid, default: 'unknown'

          # observers that will receive/handle events via delegator method
          observe ElasticSearchStub, delegator: :store
          observe EventDatabaseStub, delegator: :push
          observe RegistratorStub

          # adapter that will handle events of this class
          adapter :memory_sync
        end

        # event type alias ('access_granted')
        EvilEvents::Event.define('access_granted') do
          # payload keys
          payload :user_id, :bigdecimal, default: -1
          payload :access_level
          payload :grant_service

          # metadata keys
          metadata :datetime

          # observers that will receive/handle events via delegator method
          observe ElasticSearchStub, delegator: :store

          # adapter that will handle events of this class
          adapter :sidekiq
        end
      end.not_to raise_error
    end

    specify 'classic class definition' do
      expect do
        # event type alias ('user_registered')
        class UserRegistered < EvilEvents::Event['user_registered']
          # method that will be invoked on observers by default (delegator: option)
          default_delegator :process_event

          # emition hooks
          before_emit ->(event) {}
          after_emit  ->(event) {}
          on_error    ->(event, error) {}

          # payload keys
          payload :user_id,  EvilEvents::Types::Strict::Integer
          payload :utm_link, EvilEvents::Types::Strict::String

          # metadata keys
          metadata :timestamp
          metadata :ref_id,   :bigdecimal
          metadata :tech_msg, :comment, default: -> { 'nothing' }

          # observers that will receive/handle events via delegator method
          observe ElasticSearchStub, delegator: :store
          observe EventDatabaseStub, delegator: :push
          observe RegistratorStub

          # adapter that will handle events of this class
          adapter :memory_sync
        end

        # event type alias ('level_up')
        class LevelUp < EvilEvents::Event['level_up']
          # payload keys
          payload :player_id, EvilEvents::Types::Strict::Integer
          payload :score,     EvilEvents::Types::Strict::Float

          # metadata keys
          metadata :timestamp, :timestamp
          metadata :version

          # observers that will receive/handle events via delegator method
          observe ElasticSearchStub, delegator: :store
          observe EventDatabaseStub, delegator: :push
          observe RegistratorStub,   delegator: :process_event

          # adapter that will handle events of this class
          adapter :faktory
        end
      end.not_to raise_error
    end

    specify 'fails when event type is already in use' do
      EvilEvents::Event.define('mission_lost')
      expect { EvilEvents::Event.define('mission_lost') }.to raise_error(
        EvilEvents::AlreadyManagedEventClassError
      )

      Class.new(EvilEvents::Event['user_registered'])
      expect { Class.new(EvilEvents::Event['user_registered']) }.to raise_error(
        EvilEvents::AlreadyManagedEventClassError
      )

      expect { EvilEvents::Event.define('user_registered') }.to raise_error(
        EvilEvents::AlreadyManagedEventClassError
      )
      expect { Class.new(EvilEvents::Event['mission_lost']) }.to raise_error(
        EvilEvents::AlreadyManagedEventClassError
      )
    end

    specify 'list of created event classes' do
      class DeployFinished < EvilEvents::Event['deploy_finished']
      end

      class PullRequestCreated < EvilEvents::Event['pull_request_created']
      end

      withdraw_processed = EvilEvents::Event.define('withdraw_processed')
      deposit_rejected   = EvilEvents::Event.define('deposit_rejected')

      expect(EvilEvents::Application.registered_events).to match(
        'deploy_finished'      => DeployFinished,
        'pull_request_created' => PullRequestCreated,
        'withdraw_processed'   => withdraw_processed,
        'deposit_rejected'     => deposit_rejected
      )
    end
  end

  describe 'object creation' do
    specify 'object creation and object attributes' do
      # payload without strict types
      class DepositCreated < EvilEvents::Event['deposit_created']
        payload :user_id
        payload :deposit_id
        payload :amount

        metadata :timestamp
      end

      # can create event object with any param types
      expect do
        DepositCreated.new(
          payload:  { user_id: 1, deposit_id: 2, amount: 1_000.50 },
          metadata: { timestamp: 147_000 }
        )
      end.not_to raise_error

      # can create event object with any param types
      expect do
        DepositCreated.new(
          payload:  { user_id: '1', deposit_id: double, amount: '1_000.50' },
          metadata: { timestamp: Object.new }
        )
      end.not_to raise_error

      # payload with strict types (and default values) (by Dry::Types gem)
      DocumentRejected = EvilEvents::Event.define('document_rejected') do
        payload :document_type, EvilEvents::Types::Strict::String
        payload :reason,        EvilEvents::Types::Strict::String.default('violation')
        payload :tech_comment,  :comment, default: nil

        metadata :timestamp, EvilEvents::Types::Strict::Integer.default(0)
        metadata :server_id, :uuid, default: 'undefined'
      end

      # define event object with valid types of attributes
      expect do
        DocumentRejected.new(
          payload:  { document_type: 'bank_card', reason: 'invalid', tech_comment: 'test' },
          metadata: { timestamp: 147_555, server_id: 'A123B456C789D0' }
        )
      end.not_to raise_error

      # skip attributes with default values
      expect { DocumentRejected.new(payload: { document_type: 'test' }) }.not_to raise_error

      # skip necessary attributes
      expect { DocumentRejected.new }.to raise_error(Dry::Struct::Error)
      expect { DepositCreated.new   }.to raise_error(Dry::Struct::Error)

      # push undefined attributes
      expect do
        DocumentRejected.new(payload: { lel: 1 }, metadata: { kek: 2 })
      end.to raise_error(Dry::Struct::Error)
      expect do
        DepositCreated.new(payload: { lel: 1 }, metadata: { kek: 2 })
      end.to raise_error(Dry::Struct::Error)

      # fetching object attributes (payload and metadata)
      current_time = Time.now
      event = DepositCreated.new(
        payload:  { user_id: 2, deposit_id: 123_456, amount: 5_000.11 },
        metadata: { timestamp: current_time }
      )
      expect(event.payload).to  match(user_id: 2, deposit_id: 123_456, amount: 5_000.11)
      expect(event.metadata).to match(timestamp: current_time)

      # fetching object attributes (payload and metadata with default values)
      event = DocumentRejected.new(payload: { document_type: 'employee_data' })
      expect(event.metadata).to match(
        timestamp: 0, # Dry::Types is used
        server_id: 'undefined', # coercible type is used
      )
      expect(event.payload).to match(
        document_type: 'employee_data',
        reason:        'violation', # Dry::Types is used
        tech_comment:  nil # coercible type is used
      )

      # fetching object attributes (payload and metadata with defined default options)
      event = DocumentRejected.new(
        payload:  { document_type: 'disk_info', reason: 'broken_data', tech_comment: ' rspec ' },
        metadata: { timestamp: 666_777, server_id: 'A123B456C789D0' }
      )
      expect(event.payload).to match(
        document_type: 'disk_info',
        reason:        'broken_data',
        tech_comment:  'rspec' # coercible type is used
      )
      expect(event.metadata).to match(
        timestamp: 666_777,
        server_id: 'A***B***C***D*' # coercible type is used
      )
    end
  end

  # rubocop:disable Metrics/LineLength
  specify 'event class signature and signature equality' do
    # anonymous block definition
    deposit_approved = EvilEvents::Event.define('deposit_approved') do
      default_delegator :process_event

      payload :deposit_id, EvilEvents::Types::Strict::Integer
      payload :comment, :comment

      metadata :timestamp
      metadata :secure_id, :uuid, default: 'unknown'

      adapter :memory_sync
    end

    # constant-assigned block definition
    DepositRejected = EvilEvents::Event.define('deposit_rejected') do
      default_delegator :process_event

      payload :deposit_id, EvilEvents::Types::Strict::Integer
      payload :comment, :comment

      metadata :timestamp
      metadata :secure_id, :uuid, default: 'unknown'

      adapter :memory_sync
    end

    # anonymous class definition
    sprint_passed = Class.new(EvilEvents::Event['sprint_passed']) do
      default_delegator :manage_event

      payload :sprint_id, EvilEvents::Types::Integer

      metadata :points, EvilEvents::Types::Float

      adapter :memory_async
    end

    # constant-assigned class definition
    class SprintFailed < EvilEvents::Event['sprint_failed']
      default_delegator :manage_event

      payload :sprint_id, EvilEvents::Types::Integer

      metadata :points, EvilEvents::Types::Float

      adapter :memory_async
    end

    deposit_approved_signature = deposit_approved.signature
    deposit_rejected_signature = DepositRejected.signature
    sprint_passed_signature    = sprint_passed.signature
    sprint_failed_signature    = SprintFailed.signature

    deposit_approved_signature.tap do |signature|
      expect(signature.class_stamp).to      eq(name: nil, creation_strategy: :proc_eval)
      expect(signature.type_alias_stamp).to eq('deposit_approved')
      expect(signature.delegator_stamp).to  eq(:process_event)
      expect(signature.adapter_stamp).to    eq(memory_sync: EvilEvents::Config::Adapters[:memory_sync])

      expect(signature.payload_stamp).to match(
        deposit_id: EvilEvents::Types::Strict::Integer,
        comment:    be_a(Dry::Types::Definition)
      )

      expect(signature.metadata_stamp).to match(
        timestamp: EvilEvents::Types::Any,
        secure_id: be_a(Dry::Types::Default::Callable)
      )
    end

    deposit_rejected_signature.tap do |signature|
      expect(signature.class_stamp).to      eq(name: 'DepositRejected', creation_strategy: :proc_eval)
      expect(signature.type_alias_stamp).to eq('deposit_rejected')
      expect(signature.delegator_stamp).to  eq(:process_event)
      expect(signature.adapter_stamp).to    eq(memory_sync: EvilEvents::Config::Adapters[:memory_sync])

      expect(signature.payload_stamp).to match(
        deposit_id: EvilEvents::Types::Strict::Integer,
        comment:    be_a(Dry::Types::Definition)
      )

      expect(signature.metadata_stamp).to match(
        timestamp: EvilEvents::Types::Any,
        secure_id: be_a(Dry::Types::Default::Callable)
      )
    end

    sprint_passed_signature.tap do |signature|
      expect(signature.class_stamp).to      eq(name: nil, creation_strategy: :class_inheritance)
      expect(signature.type_alias_stamp).to eq('sprint_passed')
      expect(signature.delegator_stamp).to  eq(:manage_event)
      expect(signature.adapter_stamp).to    eq(memory_async: EvilEvents::Config::Adapters[:memory_async])
      expect(signature.payload_stamp).to    match(sprint_id: EvilEvents::Types::Integer)
      expect(signature.metadata_stamp).to   match(points: EvilEvents::Types::Float)
    end

    sprint_failed_signature.tap do |signature|
      expect(signature.class_stamp).to      eq(name: 'SprintFailed', creation_strategy: :class_inheritance)
      expect(signature.type_alias_stamp).to eq('sprint_failed')
      expect(signature.delegator_stamp).to  eq(:manage_event)
      expect(signature.adapter_stamp).to    eq(memory_async: EvilEvents::Config::Adapters[:memory_async])
      expect(signature.payload_stamp).to    match(sprint_id: EvilEvents::Types::Integer)
      expect(signature.metadata_stamp).to   match(points: EvilEvents::Types::Float)
    end

    signatures = [
      deposit_approved_signature,
      deposit_rejected_signature,
      sprint_passed_signature,
      sprint_failed_signature
    ]

    signatures.product(signatures) do |(signature_a, signature_b)|
      next if signature_a.object_id == signature_b.object_id
      expect(signature_a).not_to eq(signature_b)
    end

    similar_sprint_passed_signature = sprint_passed.signature
    expect(sprint_passed_signature).to eq(similar_sprint_passed_signature)
    expect(sprint_passed_signature.object_id).not_to eq(similar_sprint_passed_signature.object_id)

    similar_sprint_failed_signature = SprintFailed.signature
    expect(sprint_failed_signature).to eq(similar_sprint_failed_signature)
    expect(sprint_failed_signature.object_id).not_to eq(similar_sprint_failed_signature.object_id)

    similar_deposit_approved_signature = deposit_approved.signature
    expect(deposit_approved_signature).to eq(similar_deposit_approved_signature)
    expect(deposit_approved_signature.object_id).not_to eq(similar_deposit_approved_signature.object_id)

    similar_deposit_rejected_signature = DepositRejected.signature
    expect(deposit_rejected_signature).to eq(similar_deposit_rejected_signature)
    expect(deposit_rejected_signature.object_id).not_to eq(similar_deposit_rejected_signature.object_id)
  end
  # rubocop:enable Metrics/LineLength
end
