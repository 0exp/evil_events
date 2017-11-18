# frozen_string_literal: true

shared_examples 'dependency container interface' do
  describe 'public container interface' do
    # HACK: have to reset internal registry so that doesnt interfer with other specs)
    specify 'registering/resolving dependencies' do
      rand(20).times do
        random_key = gen_str
        expect { container.resolve(random_key) }.to raise_error(Dry::Container::Error)

        random_object = double
        container.register(random_key, random_object)
        expect(container.resolve(random_key)).to eq(random_object)
        expect(container[random_key]).to eq(random_object)
      end
    end

    specify 'key duplication error' do
      repeated_key = gen_symb(only_letters: true)

      expect do
        container.register(repeated_key, double)
        container.register(repeated_key, double)
      end.to raise_error(Dry::Container::Error)
    end

    specify 'dependency memoization' do
      simple_object_key  = gen_symb(only_letters: true)
      another_object_key = gen_symb(only_letters: true)

      # with memoization
      container.register(simple_object_key, memoize: true) { Object.new }
      first_resolve  = container.resolve(simple_object_key)
      second_resolve = container.resolve(simple_object_key)
      expect(first_resolve).to eq(second_resolve)

      # without memoization
      container.register(another_object_key) { Object.new }
      first_resolve  = container.resolve(another_object_key)
      second_resolve = container.resolve(another_object_key)
      expect(first_resolve).not_to eq(second_resolve)
    end

    specify 'mocking dependencies' do
      simple_dependency = double
      dependency_key    = gen_symb(only_letters: true)

      container.register(dependency_key, simple_dependency)

      container.enable_stubs!

      mocked_dependency = double
      container.stub(dependency_key, mocked_dependency)
      expect(container.resolve(dependency_key)).to eq(mocked_dependency)
      expect(container.resolve(dependency_key)).to eq(mocked_dependency)

      container.unstub
      expect(container.resolve(dependency_key)).to eq(simple_dependency)
    end
  end
end
