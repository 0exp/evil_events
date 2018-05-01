# frozen_string_literal: true

describe EvilEvents::Error do
  specify 'FailingSubscribersError structure and behaviour' do
    error_message = gen_str
    error = EvilEvents::FailingSubscribersError.new(error_message)

    # correct message
    expect(error.message).to eq(error_message)
    # empty error stack
    expect(error.empty?).to eq(true)
    expect(error.errors_stack).to eq([])

    any_error     = NoMethodError.new
    another_error = ZeroDivisionError.new

    error << any_error
    # filled errors stack
    expect(error.empty?).to eq(false)
    expect(error.errors_stack).to contain_exactly(any_error)

    error << another_error
    # filled errors stack
    expect(error.empty?).to eq(false)
    expect(error.errors_stack).to contain_exactly(any_error, another_error)
  end

  specify 'error types' do
    expect(EvilEvents::EmitterError).to                          be < described_class
    expect(EvilEvents::IncorrectEventForEmitError).to            be < described_class
    expect(EvilEvents::TypeAliasingError).to                     be < described_class
    expect(EvilEvents::IncopatibleEventTypeError).to             be < described_class
    expect(EvilEvents::EventTypeNotDefinedError).to              be < described_class
    expect(EvilEvents::EventTypeAlreadyDefinedError).to          be < described_class
    expect(EvilEvents::NotifierBuilderError).to                  be < described_class
    expect(EvilEvents::UnknownNotifierTypeError).to              be < described_class
    expect(EvilEvents::ManagerError).to                          be < described_class
    expect(EvilEvents::InconsistentEventClassError).to           be < described_class
    expect(EvilEvents::InvalidDelegatorTypeError).to             be < described_class
    expect(EvilEvents::ManagerFactoryError).to                   be < described_class
    expect(EvilEvents::IncorrectEventClassError).to              be < described_class
    expect(EvilEvents::ManagerRegistryError).to                  be < described_class
    expect(EvilEvents::IncorrectManagerObjectError).to           be < described_class
    expect(EvilEvents::NonManagedEventClassError).to             be < described_class
    expect(EvilEvents::AlreadyManagedEventClassError).to         be < described_class
    expect(EvilEvents::SerializersError).to                      be < described_class
    expect(EvilEvents::SerializationError).to                    be < described_class
    expect(EvilEvents::JSONSerializationError).to                be < described_class
    expect(EvilEvents::XMLSerializationError).to                 be < described_class
    expect(EvilEvents::HashSerializationError).to                be < described_class
    expect(EvilEvents::MessagePackSerializationError).to         be < described_class
    expect(EvilEvents::DeserializationError).to                  be < described_class
    expect(EvilEvents::JSONDeserializationError).to              be < described_class
    expect(EvilEvents::XMLDeserializationError).to               be < described_class
    expect(EvilEvents::HashDeserializationError).to              be < described_class
    expect(EvilEvents::MessagePackDeserializationError).to       be < described_class
    expect(EvilEvents::SerializationEngineError).to              be < described_class
    expect(EvilEvents::UnrecognizedSerializationEngineError).to  be < described_class
    expect(EvilEvents::NotifierError).to                         be < described_class
    expect(EvilEvents::WorkerError).to                           be < described_class
    expect(EvilEvents::IncorrectFallbackPolicyError).to          be < described_class
    expect(EvilEvents::WorkerDisabledOrBusyError).to             be < described_class
  end
end
