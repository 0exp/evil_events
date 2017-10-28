# frozen_string_literal: true

describe EvilEvents::Core::Events::ManagerFactory do
  describe '#create' do
    it 'creates new manager object with passed event class' do
      event_class_1 = build_abstract_event_class('test_event_1')
      event_class_2 = build_abstract_event_class('test_event_2')
      manager_1     = described_class.create(event_class_1)
      manager_2     = described_class.create(event_class_2)

      expect(manager_1).to be_a(EvilEvents::Core::Events::Manager)
      expect(manager_2).to be_a(EvilEvents::Core::Events::Manager)
      expect(manager_1.event_class).to eq(event_class_1)
      expect(manager_2.event_class).to eq(event_class_2)
    end

    it 'fails when receives an inconsistent event class object' do
      expect { described_class.create }.to(
        raise_error(ArgumentError)
      )

      expect { described_class.create(Object) }.to(
        raise_error(described_class::IncorrectEventClassError)
      )

      expect { described_class.create(Class) }.to(
        raise_error(described_class::IncorrectEventClassError)
      )

      expect { described_class.create(double) }.to(
        raise_error(described_class::IncorrectEventClassError)
      )
    end
  end
end
