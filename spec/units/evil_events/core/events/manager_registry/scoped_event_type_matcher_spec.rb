# frozen_string_literal: true

describe EvilEvents::Core::Events::ManagerRegistry::ScopedEventTypeMatcher do
  specify do
    matcher = described_class.new('game.#.created.#.tomorrow')
    expect(matcher.match?('game.created.tomorrow')).to eq(true)

    matcher = described_class.new('game.*.created.*.tomorrow')
    expect(matcher.match?('game.created.lel.tomorrow')).to eq(false)

    matcher = described_class.new('game.#')
    expect(matcher.match?('game.created')).to eq(true)
    expect(matcher.match?('game.created.tomorrow')).to eq(true)
    expect(matcher.match?('game')).to eq(true)
    expect(matcher.match?('user')).to eq(false)

    matcher = described_class.new('game.*')
    expect(matcher.match?('game')).to eq(false)
    expect(matcher.match?('game.created')).to eq(true)
    expect(matcher.match?('game.created.today')).to eq(false)

    matcher = described_class.new('*.created.*.*.b')
    expect(matcher.match?('a.game.created.today.b')).to eq(false)

    matcher = described_class.new('#.*.created.#.b')
    expect(matcher.match?('a.game.created.today.b')).to eq(true)

    matcher = described_class.new('deposit.created.*')
    expect(matcher.match?('deposit.created')).to eq(false)

    matcher = described_class.new('deposit.*')
    expect(matcher.match?('deposit')).to eq(false)
    expect(matcher.match?('deposit.kek')).to eq(true)
    expect(matcher.match?('deposit.kek.pek')).to eq(false)
  end
end
