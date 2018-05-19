# frozen_string_literal: true

shared_examples 'hash event serialization component' do
  describe 'hash serializer behaviour' do
    it_behaves_like 'generic event serialization component' do
      let(:serializer) { EvilEvents::Core::Events::Serializers::Hash::Factory.new.create! }
      let(:serialization_error) { EvilEvents::HashSerializationError }
      let(:deserialization_error) { EvilEvents::HashDeserializationError }
      let(:serialization_type) { Hash }
      let(:incorrect_deserialization_objects) { gen_all }
      let(:invalid_serializations) do
        key_mappings = (
          %i[type metadata payload].combination(1).to_a |
          %i[type metadata payload].combination(2).to_a |
          %i[type metadata payload].combination(3).to_a |
          %i[type metadata payload].combination(4).to_a
        )

        key_mappings.map do |key_map|
          data = serializer.serialize(event)
          data.tap { |d| key_map.each { |key| d[key] = nil } } # nullify values
        end
      end

      specify { expect(serializer).to be_a(EvilEvents::Core::Events::Serializers::Hash) }
    end
  end
end
