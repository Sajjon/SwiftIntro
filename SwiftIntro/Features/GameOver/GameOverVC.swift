//
//  GameOverVC.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 18/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import UIKit

/// The game-over screen view controller.
///
/// Thin by design: renders the outcome into `GameOverView` and wires the restart/quit
/// callbacks to navigation actions. All layout and UI state live in `GameOverView`.
final class GameOverVC: UIViewController {
    /// The configuration from the completed game, used to restart with the same level and search query.
    private let config: GameConfiguration

    /// The result of the completed game — click count, level, and the card deck.
    private let outcome: GameOutcome

    /// The root view; installed via `loadView()`.
    private let gameOverView = GameOverView()

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
        gameOverView.onRestart = { [weak self] in self?.restartGame() }
        gameOverView.onQuit = { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
}

// MARK: - Private

private extension GameOverVC {
    /// Reconstructs the navigation stack so the player re-enters a fresh game with the
    /// same images (shuffled) — without a loading screen, since images are already cached.
    ///
    /// `removeLast(2)` removes both this VC and the preceding `GameVC`, then appends
    /// the new `GameVC` so the stack ends at the game screen with no way to go back.
    func restartGame() {
        var cards = outcome.cards
        cards.shuffle()
        let gameVC = GameVC(config: config, cards: cards)
        guard var viewControllers = navigationController?.viewControllers else { return }
        viewControllers.removeLast(2)
        viewControllers.append(gameVC)
        navigationController?.setViewControllers(viewControllers, animated: false)
    }
}
