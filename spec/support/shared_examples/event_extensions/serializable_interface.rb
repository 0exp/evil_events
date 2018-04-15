# frozen_string_literal: true

shared_examples 'serializable interface' do
  describe 'serailizable behaviour' do
    let(:dumb_serializer)    { SpecSupport::DumbEventSerializer }
    let(:dumb_serial_result) { SpecSupport::DumbEventSerializer::SERIALIZATION_RESULT }

    shared_examples 'valid serialization logic' do |dependency_type, delegator|
      describe "#{dependency_type} serialization logic" do
        it 'delegates serialization logic to a special serializer' do
          EvilEvents::Core::Events::Serializers.stub(dependency_type, dumb_serializer)

          expect(EvilEvents::Core::Events::Serializers[dependency_type]).to(
            receive(:serialize).with(serializable)
          )

          serializable.public_send(delegator)
        end

        it 'returns result of serializer operations' do
          EvilEvents::Core::Events::Serializers.stub(dependency_type, dumb_serializer)
          expect(serializable.public_send(delegator)).to eq(dumb_serial_result)
        end
      end
    end

    it_behaves_like 'valid serialization logic', :hash, :serialize_to_hash
    it_behaves_like 'valid serialization logic', :json, :serialize_to_json
    it_behaves_like 'valid serialization logic', :xml,  :serialize_to_xml
  end
end
