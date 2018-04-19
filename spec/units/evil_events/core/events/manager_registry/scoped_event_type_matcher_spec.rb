# frozen_string_literal: true

describe EvilEvents::Core::Events::ManagerRegistry::ScopedEventTypeMatcher do
  let(:event_types) do
    %w[
      game
      game.created
      game.created.tomorrow
      game.created.platform.macos
      game.updated
      game.updated.platform.windows
      game.favorite.current.platform.netent
      user
      user.deposit
      user.deposit.reject
      user.signin
      user.signin.fail
      deposit
      deposit.created
      deposit.created.ecompay
      deposit.created.sberbank
      gift
      gift.offer
      gift.offer.bonus
      gift.offer.bonus.wasted
    ]
  end

  def match_with(pattern)
    matcher = described_class.new(pattern)

    event_types.select do |type|
      matcher.match?(type)
    end
  end

  specify do
    expect(match_with('game')).to contain_exactly('game')

    expect(match_with('game.#')).to contain_exactly(
      'game',
      'game.created',
      'game.created.tomorrow',
      'game.created.platform.macos',
      'game.updated',
      'game.updated.platform.windows',
      'game.favorite.current.platform.netent'
    )

    expect(match_with('game.*')).to contain_exactly(
      'game.created',
      'game.updated',
    )

    expect(match_with('game.*.tomorrow')).to contain_exactly(
      'game.created.tomorrow'
    )

    expect(match_with('game.*.platform')).to be_empty

    expect(match_with('game.*.platform.*')).to contain_exactly(
      'game.created.platform.macos',
      'game.updated.platform.windows',
    )

    expect(match_with('#.created.#')).to contain_exactly(
      'game.created',
      'game.created.tomorrow',
      'game.created.platform.macos',
      'deposit.created',
      'deposit.created.ecompay',
      'deposit.created.sberbank'
    )

    expect(match_with('*.#.created.#.platform.#.macos')).to contain_exactly(
      'game.created.platform.macos'
    )

    expect(match_with('#')).to contain_exactly(*event_types)
    expect(match_with('*')).to contain_exactly('game', 'gift', 'user', 'deposit')

    expect(match_with('#.created.*')).to contain_exactly(
      'game.created.tomorrow',
      'deposit.created.ecompay',
      'deposit.created.sberbank'
    )
  end
end
