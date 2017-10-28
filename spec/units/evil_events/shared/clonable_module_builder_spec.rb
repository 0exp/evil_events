# frozen_string_literal: true

describe EvilEvents::Shared::ClonableModuleBuilder do
  describe '.build' do
    specify "creates new module object by a proc object as it's signature" do
      expect(described_class.build).to be_a(Module)

      mod = described_class.build do
        define_method(:simple_method) { |a, b| }
        def another_method(c, d:, e: nil); end

        class << self
          define_method(:foo_method) { |a, b:| }
          def bar_method(c, d:, e:); end
        end
      end

      expect(mod.instance_methods(false)).to contain_exactly(:simple_method, :another_method)
      expect(mod.methods(false)).to contain_exactly(:foo_method, :bar_method, :module_clone)

      simple_method = mod.instance_method(:simple_method)
      expect(simple_method.parameters).to contain_exactly(
        [:req, :a], [:req, :b] # rubocop:disable Style/SymbolArray
      )

      another_method = mod.instance_method(:another_method)
      expect(another_method.parameters).to contain_exactly(
        [:req, :c], [:keyreq, :d], [:key, :e] # rubocop:disable Style/SymbolArray
      )

      foo_method = mod.method(:foo_method)
      expect(foo_method.parameters).to contain_exactly(
        [:req, :a], [:keyreq, :b] # rubocop:disable Style/SymbolArray
      )

      bar_method = mod.method(:bar_method)
      expect(bar_method.parameters).to contain_exactly(
        [:req, :c], [:keyreq, :d], [:keyreq, :e] # rubocop:disable Style/SymbolArray
      )
    end

    specify 'generated module can generate new module with the same signature by .module_clone' do
      mod = described_class.build do
        define_method(:overwatch) { |score, heroes| }
        def left_for_dead(zombies, dead:, alive: nil); end

        class << self
          define_method(:mobile_legends) { |hero, artifacts:| }
          def star_craft(map, statistics:); end
        end
      end

      new_mod = mod.module_clone

      expect(new_mod.instance_methods(false)).to contain_exactly(:overwatch, :left_for_dead)
      expect(new_mod.methods(false)).to contain_exactly(:mobile_legends, :star_craft, :module_clone)

      overwatch_method = new_mod.instance_method(:overwatch)
      expect(overwatch_method.parameters).to contain_exactly(
        [:req, :score], [:req, :heroes] # rubocop:disable Style/SymbolArray
      )

      left_for_dead_method = new_mod.instance_method(:left_for_dead)
      expect(left_for_dead_method.parameters).to contain_exactly(
        [:req, :zombies], [:keyreq, :dead], [:key, :alive] # rubocop:disable Style/SymbolArray
      )

      mobile_legends_method = new_mod.method(:mobile_legends)
      expect(mobile_legends_method.parameters).to contain_exactly(
        [:req, :hero], [:keyreq, :artifacts] # rubocop:disable Style/SymbolArray
      )

      star_craft_method = new_mod.method(:star_craft)
      expect(star_craft_method.parameters).to contain_exactly(
        [:req, :map], [:keyreq, :statistics] # rubocop:disable Style/SymbolArray
      )
    end
  end
end
