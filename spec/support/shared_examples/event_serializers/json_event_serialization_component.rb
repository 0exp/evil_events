# frozen_string_literal: true

shared_examples 'json event serialization component' do
  describe 'json serializer behaviour' do
    it_behaves_like 'generic event serialization component' do
      let(:serializer) { EvilEvents::Core::Events::Serializers::JSON::Factory.new.create! }
      let(:serialization_error) { EvilEvents::JSONSerializationError }
      let(:deserialization_error) { EvilEvents::JSONDeserializationError }
      let(:serialization_type) { String }
      let(:incorrect_deserialization_objects) { gen_all }
      let(:invalid_serializations) do
        data = serializer.serialize(event)

        [
          data.sub('type":', "\"#{gen_str}\":"),
          data.sub('payload":', "\"#{gen_str}\":"),
          data.sub('metadata":', "\"#{gen_str}\":")
        ]
      end

      specify { expect(serializer).to be_a(EvilEvents::Core::Events::Serializers::JSON) }
    end
  end
end
