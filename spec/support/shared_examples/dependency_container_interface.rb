# frozen_string_literal: true

shared_examples 'dependency container interface' do
  describe 'public container interface' do
    specify 'registering/resolving dependencies' do
      rand(20).times do
        random_key = SecureRandom.uuid
        expect { container.resolve(random_key) }.to raise_error(Dry::Container::Error)

        random_object = double
        container.register(random_key, random_object)
        expect(container.resolve(random_key)).to eq(random_object)
        expect(container[random_key]).to eq(random_object)
      end
    end

    specify 'key duplication error' do
      repeated_key = :super_mega_dependency
      expect do
        container.register(repeated_key, double)
        container.register(repeated_key, double)
      end.to raise_error(Dry::Container::Error)
    end

    specify 'dependency memoization' do
      # with memoization
      container.register(:simple_object, memoize: true) { Object.new }
      first_resolve  = container.resolve(:simple_object)
      second_resolve = container.resolve(:simple_object)
      expect(first_resolve).to eq(second_resolve)

      # without memoization
      container.register(:another_object) { Object.new }
      first_resolve  = container.resolve(:another_object)
      second_resolve = container.resolve(:another_object)
      expect(first_resolve).not_to eq(second_resolve)
    end

    specify 'mocking dependencies' do
      simple_dependency = double
      container.register(:simple_dependency, simple_dependency)

      container.enable_stubs!

      mocked_dependency = double
      container.stub(:simple_dependency, mocked_dependency)
      expect(container.resolve(:simple_dependency)).to eq(mocked_dependency)
      expect(container.resolve(:simple_dependency)).to eq(mocked_dependency)

      container.unstub
      expect(container.resolve(:simple_dependency)).to eq(simple_dependency)
    end
  end
end
