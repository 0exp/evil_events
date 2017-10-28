# frozen_string_literal: true

describe EvilEvents::Core::Broadcasting::Emitter, :stub_event_system do
  include_context 'event system'

  let(:emitter) { described_class.new }

  describe 'event handling logic' do
    let(:silent_output)   { StringIO.new }
    let(:silent_logger)   { ::Logger.new(silent_output) }
    let(:sidekiq_adapter) { build_adapter_class.new }
    let(:rabbit_adapter)  { build_adapter_class.new }
    let(:redis_adapter)   { build_adapter_class.new }

    before do
      system_config.configure do |config|
        config.logger = silent_logger
      end

      event_system.register_adapter(:sidekiq, sidekiq_adapter)
      event_system.register_adapter(:redis,   redis_adapter)
      event_system.register_adapter(:rabbit,  rabbit_adapter)
    end

    describe '#emit' do
      describe 'logging' do
        specify 'activity: event adapter name :: message: event type / event pyload' do
          # event class sample (with redis adapter)
          redis_event_class = build_event_class('excalibur_found') do
            payload :geo_location, EvilEvents::Types::Strict::String
            metadata :uuid, EvilEvents::Types::Strict::Int
            adapter :redis
          end

          # event class sample (whti rabbit adapter)
          rabbit_event_class = build_event_class('racing_finished') do
            payload :reason, EvilEvents::Types::Strict::String
            metadata :uuid, EvilEvents::Types::Strict::Int
            adapter :rabbit
          end

          # event class sample (whti sidekiq adapter)
          sidekiq_event_class = build_event_class('not_enough_money') do
            payload :money_limit, EvilEvents::Types::Strict::Float.default(0.0)
            payload :required_money, EvilEvents::Types::Strict::Float
            metadata :uuid, EvilEvents::Types::Strict::Int
            adapter :sidekiq
          end

          # event objects
          redis_event = redis_event_class.new(
            payload:  { geo_location: 'dunno' },
            metadata: { uuid: 123 }
          )
          rabbit_event = rabbit_event_class.new(
            payload:  { reason: 'dunno' },
            metadata: { uuid: 555 }
          )
          sidekiq_event = sidekiq_event_class.new(
            payload:  { required_money: 1_577.00 },
            metadata: { uuid: 712 }
          )

          # four different adapters
          [redis_event, rabbit_event, sidekiq_event].each do |event|
            # expected messages which should be processed by logger
            expected_message = Regexp.union(
              /\[EvilEvents::EventEmitted\(#{event.adapter_name}\)\]\s/,
              /ID:\s#{event.id}\s::\s/,
              /TYPE:\s#{event.type}\s::\s/,
              /PAYLOAD:\s#{event.payload}\s::\s/,
              /METADATA:\s#{event.metadata}/
            )

            # expects that logger output hasnt expected messages
            expect(silent_output.string).not_to match(expected_message)

            # emit event (and log :))
            emitter.emit(event)

            # epxects that logger output has expectedd messages
            expect(silent_output.string).to match(expected_message)
          end
        end
      end

      describe 'event handling', :null_logger do
        it 'delegates event handling to appropriate pre-configured adapter' do
          redis_event   = build_event_class('redis_event')   { adapter :redis }.new
          sidekiq_event = build_event_class('sidekiq_event') { adapter :sidekiq }.new
          rabbit_event  = build_event_class('rabbit_event')  { adapter :rabbit }.new

          expect(redis_adapter).to   receive(:call).with(redis_event).twice
          expect(sidekiq_adapter).to receive(:call).with(sidekiq_event).twice
          expect(rabbit_adapter).to  receive(:call).with(rabbit_event).twice

          emitter.emit(redis_event)
          emitter.emit(redis_event)
          emitter.emit(rabbit_event)
          emitter.emit(rabbit_event)
          emitter.emit(sidekiq_event)
          emitter.emit(sidekiq_event)
        end
      end

      it 'fails when event object is incorrect' do
        expect { emitter.emit(double) }.to raise_error(described_class::IncorrectEventError)
        expect { emitter.emit build_event_class('test_event').new }.not_to raise_error
      end
    end

    describe '#raw_emit' do
      describe 'logging' do
        specify 'activity: event adapter name :: message: event type / event pyload' do
          # event class sample (with redis adapter)
          build_event_class('excalibur_found') do
            payload :geo_location, EvilEvents::Types::Strict::String
            metadata :id, EvilEvents::Types::Strict::Int.default(-1)
            adapter :redis
          end

          # event class sample (whti rabbit adapter)
          build_event_class('racing_finished') do
            payload :race, EvilEvents::Types::Strict::String.default('rocket')
            payload :reason, EvilEvents::Types::Strict::String
            metadata :uuid, EvilEvents::Types::Strict::String
            adapter :rabbit
          end

          # event class sample (whti sidekiq adapter)
          build_event_class('not_enough_money') do
            payload :money_limit, EvilEvents::Types::Strict::Float.default(123_777.70)
            payload :required_money, EvilEvents::Types::Strict::Float
            metadata :user_id, EvilEvents::Types::Strict::Int
            adapter :sidekiq
          end

          event_definitions = {
            redis: {
              type: 'excalibur_found',
              payload: { geo_location: 'kek' },
              metadata: {},
              default_payload: {},
              default_metadata: { id: -1 }
            },
            rabbit: {
              type: 'racing_finished',
              payload: { reason: 'dunno' },
              metadata: { uuid: 'test1-spec2' },
              default_payload: { race: 'rocket' },
              default_metadata: {}
            },
            sidekiq: {
              type: 'not_enough_money',
              payload: { required_money: 14_577.20 },
              metadata: { user_id: 52_123_123 },
              default_payload: { money_limit: 123_777.70 },
              default_metadata: {}
            }
          }

          event_definitions.each_pair do |event_adapter, event_attrs|
            expected_adapter = event_adapter
            expected_type    = event_attrs[:type]
            event_payload    = event_attrs[:default_payload].merge(event_attrs[:payload])
            event_metadata   = event_attrs[:default_metadata].merge(event_attrs[:metadata])

            expected_message = Regexp.union(
              /\[EvilEvents:EventEmitted\(#{expected_adapter}\)\]\s/,
              /UUID:\s[a-b0-9\-]s\s::\s/,
              /TYPE:\s#{expected_type}\s::\s/,
              /PAYLOAD:\s#{event_payload}\s::\s/,
              /METADATA:\s#{event_metadata}/
            )

            expect(silent_output.string).not_to match(expected_message)

            emitter.raw_emit(
              event_attrs[:type],
              payload: event_attrs[:payload],
              metadata: event_attrs[:metadata]
            )

            expect(silent_output.string).to match(expected_message)
          end
        end
      end

      describe 'event handling', :null_logger do
        describe 'recognition and processing' do
          it 'recognizes an event object based on the passed type alias and payload' \
             'and delegates event handling to the appropriate pre-configured adapter' do
            game_over_event_class = build_event_class('game_over') do
              payload :player
              payload :score
              adapter :sidekiq
            end

            finished_event_class = build_event_class('finished') do
              payload :project_id, EvilEvents::Types::Strict::Int
              payload :assignee_id, EvilEvents::Types::Strict::Int.default(-1)
              metadata :uuid, EvilEvents::Types::Strict::String.default('undefined')
              adapter :rabbit
            end

            expect(sidekiq_adapter).to receive(:call).with(kind_of(game_over_event_class)).twice
            emitter.raw_emit('game_over', payload: { player: 'savior', score: 777_777 })
            emitter.raw_emit('game_over', payload: { player: 'pikachu', score: 0 })

            expect(rabbit_adapter).to receive(:call).with(kind_of(finished_event_class)).twice
            emitter.raw_emit('finished', payload: { project_id: 1, assignee_id: 555 })
            emitter.raw_emit('finished', payload: { project_id: 5 }, metadata: { uuid: 'asdf555' })
          end
        end

        specify 'event object recognition works correct' do
          # register event
          build_event_class('tests_finished') do
            payload :failed, EvilEvents::Types::Strict::Int
            payload :passed, EvilEvents::Types::Strict::Int
            payload :rank, EvilEvents::Types::Strict::String.default('undefined')
            metadata :timestamp, EvilEvents::Types::Strict::Int
            metadata :uuid, EvilEvents::Types::Strict::String
            adapter :sidekiq
          end

          # verify recognized event object
          expect(sidekiq_adapter).to receive(:call).with(
            have_attributes(
              type: 'tests_finished',
              payload: match(
                failed: 3_252,
                passed: 1_200,
                rank: 'apocalypse'
              ),
              metadata: match(
                timestamp: 11_111,
                uuid: 'ui11-sp22-ee33'
              )
            )
          )
          emitter.raw_emit(
            'tests_finished',
            payload: { failed: 3_252, passed: 1_200, rank: 'apocalypse' },
            metadata: { timestamp: 11_111, uuid: 'ui11-sp22-ee33' }
          )

          # verify another recognized event object
          expect(sidekiq_adapter).to receive(:call).with(
            have_attributes(
              type: 'tests_finished',
              payload: match(
                failed: 0,
                passed: 10_182,
                rank: 'god'
              ),
              metadata: match(
                timestamp: 14_777,
                uuid: 'keks-shmeks-peks'
              )
            )
          )
          emitter.raw_emit(
            'tests_finished',
            payload: { failed: 0, passed: 10_182, rank: 'god' },
            metadata: { timestamp: 14_777, uuid: 'keks-shmeks-peks' }
          )

          # register event
          build_event_class('event_pushed') do
            payload :pusher
            payload :comment, EvilEvents::Types::Strict::String
            adapter :redis
          end

          first_pusher = double
          # verify recognized event object
          expect(redis_adapter).to receive(:call).with(
            have_attributes(
              type: 'event_pushed',
              payload: match(
                pusher: first_pusher,
                comment: 'hello_world!'
              ),
              metadata: match({})
            )
          )

          emitter.raw_emit(
            'event_pushed',
            payload: { pusher: first_pusher, comment: 'hello_world!' }
          )

          second_pusher = double
          # verify another recognized event object
          expect(redis_adapter).to receive(:call).with(
            have_attributes(
              type: 'event_pushed',
              payload: match(
                pusher: second_pusher,
                comment: 'completed'
              ),
              metadata: match({})
            )
          )

          emitter.raw_emit(
            'event_pushed',
            payload: { pusher: second_pusher, comment: 'completed' }
          )
        end
      end

      it 'fails when event object cant be recognized (or event attributes are incorrect)' do
        build_event_class('simple_event') do
          payload :id, EvilEvents::Types::Strict::Int.default(123)
          payload :test, EvilEvents::Types::Strict::String
          metadata :uuid, EvilEvents::Types::Strict::String.default('test')
        end

        expect { emitter.raw_emit }.to raise_error(ArgumentError)
        expect { emitter.raw_emit(double, double) }.to raise_error(ArgumentError)

        # invalid attribute types
        expect do
          emitter.raw_emit('simple_event')
        end.to raise_error(Dry::Struct::Error)

        # invalid attribute types
        expect do
          emitter.raw_emit('simple_event', payload: { test: 123 })
        end.to raise_error(Dry::Struct::Error)

        # invalid attribute types
        expect do
          emitter.raw_emit(
            'simple_event',
            payload: { test: 'test', id: '123' },
            metadata: { uuid: 1 }
          )
        end.to raise_error(Dry::Struct::Error)

        # valid attribute types
        expect do
          emitter.raw_emit('simple_event', payload: { test: 'test' })
        end.not_to raise_error

        # valid attribute types
        expect do
          emitter.raw_emit('simple_event', payload: { test: 'test', id: 123 })
        end.not_to raise_error

        # valid attribute types
        expect do
          emitter.raw_emit(
            'simple_event',
            payload: { test: 'test', id: 123 },
            metadata: { uuid: 'test-test-test' }
          )
        end.not_to raise_error
      end
    end
  end
end
