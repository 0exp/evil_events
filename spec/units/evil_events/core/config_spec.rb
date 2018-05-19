# frozen_string_literal: true

describe EvilEvents::Core::Config do
  let(:config) { described_class.new }

  # rubocop:disable Metrics/LineLength
  specify 'default options' do
    expect(config.settings.adapter.default).to                          eq(:memory_sync)
    expect(config.settings.subscriber.default_delegator).to             eq(:call)
    expect(config.settings.logger).to                                   be_a(EvilEvents::Shared::Logger)
    expect(config.settings.serializers.json.engine).to                  eq(:native)
    expect(config.settings.serializers.hashing.engine).to               eq(:native)
    expect(config.settings.serializers.xml.engine).to                   eq(:ox)
    expect(config.settings.serializers.msgpack.engine).to               eq(:mpacker)
    expect(config.settings.serializers.msgpack.mpacker.configurator).to be_a(Proc)
    expect(config.settings.notifier.type).to                            eq(:sequential)
    expect(config.settings.notifier.worker.min_threads).to              eq(0)
    expect(config.settings.notifier.worker.max_threads).to              eq(5)
    expect(config.settings.notifier.worker.max_queue).to                eq(1_000)
    expect(config.settings.notifier.worker.fallback_policy).to          eq(:main_thread)
  end
  # rubocop:enable Metrics/LineLength

  specify 'all meaningful options are configurable' do
    2.times do
      opts = {
        adapter_default:                  gen_symb,
        subscriber_default_delegator:     gen_symb,
        logger:                           gen_symb,
        serializers_json_engine:          gen_symb,
        serializers_hashing_engine:       gen_symb,
        serializers_xml_engine:           gen_symb,
        serializers_msgpack_engine:       gen_symb,
        serializers_msgpack_configurator: gen_symb,
        notifier_type:                    gen_symb,
        notifier_worker_min_threads:      gen_symb,
        notifier_worker_max_threads:      gen_symb,
        notifier_worker_max_queue:        gen_symb,
        notifier_worker_fallback_policy:  gen_symb
      }

      config.configure do |c|
        c.adapter.default                          = opts[:adapter_default]
        c.subscriber.default_delegator             = opts[:subscriber_default_delegator]
        c.logger                                   = opts[:logger]
        c.serializers.json.engine                  = opts[:serializers_json_engine]
        c.serializers.hashing.engine               = opts[:serializers_hashing_engine]
        c.serializers.xml.engine                   = opts[:serializers_xml_engine]
        c.serializers.msgpack.engine               = opts[:serializers_msgpack_engine]
        c.serializers.msgpack.mpacker.configurator = opts[:serializers_msgpack_configurator]
        c.notifier.type                            = opts[:notifier_type]
        c.notifier.worker.min_threads              = opts[:notifier_worker_min_threads]
        c.notifier.worker.max_threads              = opts[:notifier_worker_max_thre]
        c.notifier.worker.max_queue                = opts[:notifier_worker_max_queue]
        c.notifier.worker.fallback_policy          = opts[:notifier_worker_fallback_policy]
      end

      expect(config.settings.adapter.default).to(
        eq(opts[:adapter_default])
      )
      expect(config.settings.subscriber.default_delegator).to(
        eq(opts[:subscriber_default_delegator])
      )
      expect(config.settings.logger).to(
        eq(opts[:logger])
      )
      expect(config.settings.serializers.json.engine).to(
        eq(opts[:serializers_json_engine])
      )
      expect(config.settings.serializers.hashing.engine).to(
        eq(opts[:serializers_hashing_engine])
      )
      expect(config.settings.serializers.xml.engine).to(
        eq(opts[:serializers_xml_engine])
      )
      expect(config.settings.serializers.msgpack.engine).to(
        eq(opts[:serializers_msgpack_engine])
      )
      expect(config.settings.serializers.msgpack.mpacker.configurator).to(
        eq(opts[:serializers_msgpack_configurator])
      )
      expect(config.settings.notifier.type).to(
        eq(opts[:notifier_type])
      )
      expect(config.settings.notifier.worker.min_threads).to(
        eq(opts[:notifier_worker_min_threads])
      )
      expect(config.settings.notifier.worker.max_threads).to(
        eq(opts[:notifier_worker_max_thre])
      )
      expect(config.settings.notifier.worker.max_queue).to(
        eq(opts[:notifier_worker_max_queue])
      )
      expect(config.settings.notifier.worker.fallback_policy).to(
        eq(opts[:notifier_worker_fallback_policy])
      )
    end
  end
end
