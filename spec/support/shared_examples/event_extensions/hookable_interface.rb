# frozen_string_literal: true

shared_examples 'hookable interface' do
  describe 'before emit hooks' do
    specify '#__call_before_hooks__' do
      first_buffer  = []
      second_buffer = []
      third_buffer  = []

      hookable.before_emit ->(instance) { first_buffer  << :first_invoked }
      hookable.before_emit ->(instance) { first_buffer  << :second_invoked }
      hookable.before_emit ->(instance) { second_buffer << :third_invoked }
      hookable.before_emit ->(instance) { third_buffer  << instance }

      hooker = hookable.new
      hooker.__call_before_hooks__

      expect(first_buffer).to  contain_exactly(:first_invoked, :second_invoked)
      expect(second_buffer).to contain_exactly(:third_invoked)
      expect(third_buffer).to  contain_exactly(hooker)
    end
  end

  describe 'after emit hooks' do
    specify '#__call_after_hooks__' do
      first_buffer  = []
      second_buffer = []
      third_buffer  = []

      hookable.after_emit ->(instance) { first_buffer  << :first_invoked }
      hookable.after_emit ->(instance) { first_buffer  << :second_invoked }
      hookable.after_emit ->(instance) { second_buffer << :third_invoked }
      hookable.after_emit ->(instance) { third_buffer  << instance }

      hooker = hookable.new
      hooker.__call_after_hooks__

      expect(first_buffer).to  contain_exactly(:first_invoked, :second_invoked)
      expect(second_buffer).to contain_exactly(:third_invoked)
      expect(third_buffer).to  contain_exactly(hooker)
    end
  end

  describe 'on error hooks' do
    specify '#__call_on_error_hooks__' do
      first_buffer  = []
      second_buffer = []
      third_buffer  = []

      hookable.on_error ->(instance, error) { first_buffer  << :first_invoked }
      hookable.on_error ->(instance, error) { first_buffer  << error }
      hookable.on_error ->(instance, error) { second_buffer << :third_invoked }
      hookable.on_error ->(instance, error) { third_buffer  << instance }
      hookable.on_error ->(instance, error) { third_buffer  << error }

      hooker = hookable.new
      error  = StandardError.new

      hooker.__call_on_error_hooks__(error)

      expect(first_buffer).to  contain_exactly(:first_invoked, error)
      expect(second_buffer).to contain_exactly(:third_invoked)
      expect(third_buffer).to  contain_exactly(hooker, error)
    end
  end
end
