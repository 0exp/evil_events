# frozen_string_literal: ture

shared_examples 'notifier callbacks invokation interface' do
  describe 'callbacks invokation', :null_logger do
    let(:event_class)   { build_event_class(gen_str(only_letters: true)) }
    let(:event_manager) { build_event_manager(event_class) }
    let(:event)         { event_class.new }

    specify 'invokes callbacks in order BEFORE => ON ERROR => AFTER' do
      before_emit_hook_buffer = []
      after_emit_hook_buffer  = []
      on_error_hook_buffer    = []

      hook_results = (1..10).to_a

      event_class.before_emit ->(event) { before_emit_hook_buffer << hook_results.shift }
      event_class.before_emit ->(event) { before_emit_hook_buffer << hook_results.shift }
      event_class.after_emit  ->(event) { after_emit_hook_buffer << hook_results.shift }
      event_class.after_emit  ->(event) { after_emit_hook_buffer << hook_results.shift }
      event_class.on_error    ->(event, error) { on_error_hook_buffer << error }

      successfull_subscriber = ->(event) {}
      event_manager.observe(successfull_subscriber, :call)
      notifier.notify(event_manager, event)

      expect(before_emit_hook_buffer).to contain_exactly(1, 2)
      expect(after_emit_hook_buffer).to contain_exactly(3, 4)
      expect(on_error_hook_buffer).to be_empty

      failing_subscriber = ->(event) { raise ArgumentError }
      event_manager.observe(failing_subscriber, :call)

      begin
        notifier.notify(event_manager, event)
      rescue EvilEvents::FailedNotifiedSubscribersError
      end

      expect(before_emit_hook_buffer).to contain_exactly(1, 2, 5, 6)
      expect(after_emit_hook_buffer).to contain_exactly(3, 4, 7, 8)
      expect(on_error_hook_buffer).to match([be_a(ArgumentError)])
    end
  end
end
