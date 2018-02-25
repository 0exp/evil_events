# frozen_string_literal: true

describe EvilEvents::Core::Events::ManagerRegistry do
  describe 'instantiation' do
    specify 'requires nothing' do
      expect { described_class.new }.not_to raise_error
    end

    specify 'has empty managers map after instantiation' do
      expect(described_class.new.managers).to be_empty
    end
  end

  describe 'public interface', :mock_event_system do
    let(:registry) { described_class.new }

    let(:first_event_class) { build_event_class('first_event') }
    let(:second_event_class) { build_event_class('second_event') }
    let(:duplicated_first_event_class) { build_event_class('first_event') }

    let(:first_manager) { build_event_manager(first_event_class) }
    let(:second_manager) { build_event_manager(second_event_class) }
    let(:duplicated_manager) { build_event_manager(duplicated_first_event_class) }

    describe 'manager registration interface' do
      describe '#register' do
        context 'when passed manager isnt Manager object' do
          it 'fails with appropriate error' do
            expect { registry.register(double) }.to(
              raise_error(EvilEvents::IncorrectManagerObjectError)
            )

            expect { registry.register(first_manager) }.not_to raise_error
          end
        end

        context 'when registry doesnt have manager of passed event class' do
          it "registers passed manager object (manager's event_class => manager_object map)" do
            expect(registry).not_to include(first_manager)
            expect(registry).not_to include(second_manager)

            expect { registry.register(first_manager) }.not_to raise_error
            expect(registry).to include(first_manager)

            expect { registry.register(second_manager) }.not_to raise_error
            expect(registry).to include(first_manager)
            expect(registry).to include(second_manager)
          end
        end

        context 'when we tries to register already registered manager' do
          before do
            registry.register(first_manager)
            registry.register(second_manager)
          end

          it "re-registers passed manager objet (manager's event_class => manager_object map)" do
            expect(registry).to include(first_manager)
            expect(registry).to include(second_manager)
            expect(registry.size).to eq(2)

            expect { registry.register(first_manager)  }.not_to raise_error
            expect { registry.register(second_manager) }.not_to raise_error

            expect(registry.size).to eq(2)
            expect(registry).to include(first_manager)
            expect(registry).to include(second_manager)
          end
        end

        context 'when we tries to register a manager of already registered event type alias' do
          before { registry.register(first_manager) }

          it 'fails with appropriate error' do
            expect { registry.register(duplicated_manager) }.to(
              raise_error(EvilEvents::AlreadyManagedEventClassError)
            )

            expect(registry).not_to include(duplicated_manager)
            expect(registry).to     include(first_manager)
          end
        end
      end

      describe '#register_with (with event class)' do
        context 'when registry doesnt have manager of passed event class' do
          it 'registers new dynamcally created manager' do
            expect(registry.managed_event?(first_event_class)).to eq(false)
            expect(registry.size).to eq(0)

            expect { registry.register_with(first_event_class) }.not_to raise_error

            expect(registry.managed_event?(first_event_class)).to eq(true)
            expect(registry.size).to eq(1)
          end
        end

        context 'when passed event class is already managed by any registered manager' do
          before { registry.register(first_manager) }

          it 're-registers manager of already managed event class' do
            expect(registry).to include(first_manager)
            expect(registry.managed_event?(first_event_class)).to eq(true)
            expect(registry.size).to eq(1)

            registry.register_with(first_event_class)
            expect(registry).not_to include(first_manager)
            expect(registry.managed_event?(first_event_class)).to eq(true)
            expect(registry.size).to eq(1)
          end
        end

        context 'when passed event has the same type alias of the another managed event' do
          before { registry.register(first_manager) }

          it 'fails with appropriate error' do
            expect { registry.register_with(duplicated_first_event_class) }.to(
              raise_error(EvilEvents::AlreadyManagedEventClassError)
            )

            expect(registry).to include(first_manager)
            expect(registry.managed_event?(first_event_class)).to eq(true)
            expect(registry.size).to eq(1)
          end
        end
      end

      describe '#unregister' do
        it 'unregisters passed event manager' do
          registry.register(first_manager)
          registry.register(second_manager)

          registry.unregister(first_manager)
          expect(registry).not_to include(first_manager)
          expect(registry).to     include(second_manager)

          registry.unregister(second_manager)
          expect(registry).not_to include(first_manager)
          expect(registry).not_to include(second_manager)
        end
      end

      describe '#unregister_with' do
        it 'unregisters manager of passed event' do
          registry.register(first_manager)
          registry.register(second_manager)

          registry.unregister_with(first_event_class)
          expect(registry).not_to include(first_manager)
          expect(registry).to     include(second_manager)

          registry.unregister_with(second_event_class)
          expect(registry).not_to include(first_manager)
          expect(registry).not_to include(second_manager)
        end
      end
    end

    describe 'common interface' do
      describe '#managed_events_map' do
        it 'retruns an event class list in event_class.type => event_class hash form' do
          expect(registry.managed_events_map).to eq({}) # empty in start

          registry.register(first_manager)
          expect(registry.managed_events_map).to match(
            first_event_class.type => first_event_class
          )

          registry.register(second_manager)
          expect(registry.managed_events_map).to match(
            first_event_class.type  => first_event_class,
            second_event_class.type => second_event_class
          )

          registry.unregister(first_manager)
          expect(registry.managed_events_map).to match(
            second_event_class.type => second_event_class
          )

          registry.unregister(second_manager)
          expect(registry.managed_events_map).to eq({})
        end
      end

      describe '#managed_event?' do
        it 'required event class is managed => true, otherwise => false' do
          expect(registry.managed_event?(first_event_class)).to  eq(false)
          expect(registry.managed_event?(second_event_class)).to eq(false)

          registry.register(first_manager)
          expect(registry.managed_event?(first_event_class)).to  eq(true)
          expect(registry.managed_event?(second_event_class)).to eq(false)

          registry.register(second_manager)
          expect(registry.managed_event?(first_event_class)).to  eq(true)
          expect(registry.managed_event?(second_event_class)).to eq(true)

          registry.unregister(first_manager)
          expect(registry.managed_event?(first_event_class)).to  eq(false)
          expect(registry.managed_event?(second_event_class)).to eq(true)

          registry.unregister(second_manager)
          expect(registry.managed_event?(first_event_class)).to  eq(false)
          expect(registry.managed_event?(second_event_class)).to eq(false)
        end
      end

      describe 'fetching event manager objects' do
        context 'when registry has manager of required event' do
          before do
            registry.register(first_manager)
            registry.register(second_manager)
          end

          describe '#manager_of_event' do
            it 'returns manager of required event by event class' do
              expect(registry.manager_of_event(first_event_class)).to  eq(first_manager)
              expect(registry.manager_of_event(second_event_class)).to eq(second_manager)
            end
          end

          describe '#manager_of_event_type' do
            it 'returns manager of required event by event type alias' do
              expect(registry.manager_of_event_type(first_event_class.type)).to eq(
                first_manager
              )

              expect(registry.manager_of_event_type(second_event_class.type)).to eq(
                second_manager
              )
            end
          end

          describe '#managers_of_event_pattern' do
            it 'returns manager of required event by type alias regexp' do
              first_event_pattern = /\Afirst_event\z/

              expect(registry.managers_of_event_pattern(first_event_pattern)).to contain_exactly(
                first_manager
              )

              second_event_pattern = /\Asecond_event\z/

              expect(registry.managers_of_event_pattern(second_event_pattern)).to contain_exactly(
                second_manager
              )

              all_in_pattern = /.+/

              expect(registry.managers_of_event_pattern(all_in_pattern)).to contain_exactly(
                first_manager,
                second_manager
              )
            end
          end

          describe '#managers_of_event_condition' do
            it 'returns a list of managers which aliases has passed required condition (proc)' do
              condition = ->(event_type) { event_type.match(/\A[a-z]+_[a-z]+\z/i) }

              expect(registry.managers_of_event_condition(condition)).to contain_exactly(
                first_manager,
                second_manager
              )

              condition = ->(event_type) { event_type == 'first_event' }

              expect(registry.managers_of_event_condition(condition)).to contain_exactly(
                first_manager
              )

              condition = ->(event_type) { event_type == 'second_event' }

              expect(registry.managers_of_event_condition(condition)).to contain_exactly(
                second_manager
              )
            end
          end
        end

        context 'when registry doesnt have manager of required event' do
          describe '#manager_of_event' do
            it 'fails with appropriate error' do
              expect { registry.manager_of_event(first_event_class) }.to(
                raise_error(EvilEvents::NonManagedEventClassError)
              )
            end
          end

          describe '#manager_of_event_type' do
            it 'fails with appropirated error' do
              expect { registry.manager_of_event_type('test_event') }.to(
                raise_error(EvilEvents::NonManagedEventClassError)
              )
            end
          end

          describe '#managers_of_event_pattern' do
            it 'fails with appropriate error' do
              expect(registry.managers_of_event_pattern(/\Afirst_event\z/)).to   eq([])
              expect(registry.managers_of_event_pattern(/\Asecond_event\z/)).to  eq([])
              expect(registry.managers_of_event_pattern(/\A.+\z/)).to eq([])
            end
          end

          describe '#manager_of_event_condition' do
            it 'returns an empty collection' do
              expect(registry.managers_of_event_condition(proc {})).to eq([])
            end
          end
        end
      end

      describe '#include?' do
        subject { registry.include?(first_manager) }

        context 'when passed manager is registered' do
          before { registry.register(first_manager) }

          it { is_expected.to eq(true) }
        end

        context 'when passed manager isnt registered' do
          it { is_expected.to eq(false) }
        end
      end

      describe '#size' do
        it 'returns a count of registered managers' do
          expect(registry.size).to eq(0)

          registry.register(first_manager)
          expect(registry.size).to eq(1)

          registry.register(second_manager)
          expect(registry.size).to eq(2)

          registry.unregister(first_manager)
          expect(registry.size).to eq(1)

          registry.unregister(second_manager)
          expect(registry.size).to eq(0)

          registry.register_with(first_event_class)
          expect(registry.size).to eq(1)

          registry.register_with(second_event_class)
          expect(registry.size).to eq(2)

          registry.unregister_with(second_event_class)
          expect(registry.size).to eq(1)

          registry.unregister_with(first_event_class)
          expect(registry.size).to eq(0)
        end
      end

      describe '#empty?' do
        it 'registered managers exists => true, otherwise => false' do
          expect(registry).to be_empty

          registry.register(first_manager)
          expect(registry).not_to be_empty

          registry.register(second_manager)
          expect(registry).not_to be_empty

          registry.unregister(first_manager)
          expect(registry).not_to be_empty

          registry.unregister(second_manager)
          expect(registry).to be_empty
        end
      end
    end
  end
end
