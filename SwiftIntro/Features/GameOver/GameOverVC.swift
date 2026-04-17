//
//  GameOverVC.swift
//
//  Created by Alexander Cyon on 18/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import UIKit

// MARK: - GameOverNavigatorProtocol

/// Handles navigation triggered by `GameOverVC` — restart or quit.
protocol GameOverNavigatorProtocol: AnyObject {
    /// Replaces the current game and game-over screens with a new game using the same
    /// images (freshly shuffled). Called when the player taps "Restart".
    func restartGame(_ game: AnyPreparedGame)

    /// Pops back to the GameSetup screen. Called when the player taps "Quit".
    func quitGame()
}

// MARK: - GameOverVC

/// The game-over screen view controller.
///
/// Non-generic: holds an `AnyGameOutcome` and dispatches on the enum case when the
/// player taps restart. Making this VC generic would force the navigator back up the
/// stack to become generic too, without any rendering benefit — `GameOverView` only
/// needs `level` and `clickCount`.
final class GameOverVC: UIViewController {
    /// The configuration from the completed game, passed to `navigator` on restart.
    private let config: GameConfiguration

    /// The result of the completed game — click count, level, and the card deck.
    private let outcome: AnyGameOutcome

    /// The root view; installed via `loadView()`.
    private let gameOverView = GameOverView()

    /// Wired by the presenting controller (e.g. `RootVC`) before the push.
    weak var navigator: GameOverNavigatorProtocol?

    init(
        config: GameConfiguration,
        outcome: AnyGameOutcome
    ) {
        self.config = config
        self.outcome = outcome
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    override func loadView() {
        view = gameOverView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // swiftformat:disable:next redundantSelf
        logGame.notice("Game over screen shown — outcome: \(self.outcome)")
        gameOverView.render(outcome)
        gameOverView.onRestart = { [weak self] in
            guard let self else { return }
            logGame.info("Player chose Restart — starting new game with same images")
            navigator?.restartGame(preparedGameForRestart())
        }
        gameOverView.onQuit = { [weak self] in
            guard let self else { return }
            logGame.info("Player chose Quit — returning to GameSetup screen")
            navigator?.quitGame()
        }
    }
}

// MARK: - Private

private extension GameOverVC {
    /// Builds the `AnyPreparedGame` for a restart, preserving the compile-time `N` of
    /// the original outcome.
    func preparedGameForRestart() -> AnyPreparedGame {
        switch outcome {
        case let .easy(o):
            .easy(PreparedGame<6>(config: config, cards: o.cards))
        case let .normal(o):
            .normal(PreparedGame<12>(config: config, cards: o.cards))
        case let .hard(o):
            .hard(PreparedGame<20>(config: config, cards: o.cards))
        }
    }
}
