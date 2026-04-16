//
//  GameOverVC.swift
//
//  Created by Alexander Cyon on 18/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import UIKit

// MARK: - GameOverNavigatorProtocol

/// Handles navigation triggered by `GameOverVC` — restart or quit.
///
/// Conforming to this protocol rather than coupling directly to `UINavigationController`
/// keeps `GameOverVC` navigation-agnostic and makes it trivially testable.
@MainActor
protocol GameOverNavigatorProtocol: AnyObject {
    /// Replaces the current game and game-over screens with a new game using the same
    /// images (freshly shuffled). Called when the player taps "Restart".
    func restartGame(
        config: GameConfiguration,
        cards: CardDuplicates
    )

    /// Pops back to the settings screen. Called when the player taps "Quit".
    func quitGame()
}

// MARK: - GameOverVC

/// The game-over screen view controller.
///
/// Thin by design: renders the outcome into `GameOverView` and delegates all
/// navigation to `navigator`. No navigation logic lives here.
final class GameOverVC: UIViewController {
    /// The configuration from the completed game, passed to `navigator` on restart.
    private let config: GameConfiguration

    /// The result of the completed game — click count, level, and the card deck.
    private let outcome: GameOutcome

    /// The root view; installed via `loadView()`.
    private let gameOverView = GameOverView()

    /// Wired by the presenting controller (e.g. `SettingsVC`) before the push.
    weak var navigator: GameOverNavigatorProtocol?

    init(
        config: GameConfiguration,
        outcome: GameOutcome
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
        gameOverView.render(outcome)
        gameOverView.onRestart = { [weak self] in
            guard let self else { return }
            navigator?.restartGame(config: config, cards: outcome.cards)
        }
        gameOverView.onQuit = { [weak self] in
            self?.navigator?.quitGame()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
}
