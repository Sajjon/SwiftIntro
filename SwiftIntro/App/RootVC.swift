//
//  RootVC.swift
//  SwiftIntro
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import UIKit

/// The app's navigation coordinator.
///
/// `RootVC` owns the `UINavigationController` stack and handles every screen
/// transition in the game flow:
///
///     Boot → GameSetupVC → LoadingVC → GameVC → GameOverVC → GameSetupVC
///
/// All navigator protocols are implemented here so that individual view
/// controllers stay navigation-agnostic — they call a protocol method and
/// never touch the navigation stack directly.
final class RootVC: UINavigationController {
    init() {
        let gameSetupVC = GameSetupVC()
        super.init(rootViewController: gameSetupVC)
        isNavigationBarHidden = true
        gameSetupVC.navigator = self
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }
}

// MARK: - GameSetupNavigatorProtocol

extension RootVC: GameSetupNavigatorProtocol {
    /// Pushes the loading screen onto the stack to begin data fetching.
    func startGame(config: GameConfiguration) {
        let loadingVC = LoadingVC(config: config)
        loadingVC.navigator = self
        pushViewController(loadingVC, animated: true)
    }
}

// MARK: - LoadingNavigatorProtocol

extension RootVC: LoadingNavigatorProtocol {
    /// Replaces `LoadingVC` with `GameVC` so the player cannot back-swipe to the loading screen.
    func navigateToGame(
        config: GameConfiguration,
        cards: CardDuplicates
    ) {
        let gameVC = GameVC(config: config, cards: cards)
        gameVC.navigator = self
        var vcs = viewControllers
        guard !vcs.isEmpty else {
            log.error("navigateToGame: navigation stack is empty — cannot replace last VC")
            return
        }
        vcs[vcs.count - 1] = gameVC
        setViewControllers(vcs, animated: false)
    }
}

// MARK: - GameNavigatorProtocol

extension RootVC: GameNavigatorProtocol {
    /// Pushes `GameOverVC` after the final flip animation completes.
    func navigateToGameOver(outcome: GameOutcome) {
        let config = GameConfiguration(level: outcome.level)
        let gameOverVC = GameOverVC(config: config, outcome: outcome)
        gameOverVC.navigator = self
        pushViewController(gameOverVC, animated: true)
    }
}

// MARK: - GameOverNavigatorProtocol

extension RootVC: GameOverNavigatorProtocol {
    /// Replaces `GameOverVC` + `GameVC` with a new `GameVC` using the same images reshuffled.
    func restartGame(
        config: GameConfiguration,
        cards: CardDuplicates
    ) {
        var shuffled = cards
        shuffled.shuffle()
        let gameVC = GameVC(config: config, cards: shuffled)
        gameVC.navigator = self
        var vcs = viewControllers
        guard vcs.count >= 2 else {
            log.error("restartGame: navigation stack too shallow — expected at least 2")
            return
        }
        vcs.removeLast(2)
        vcs.append(gameVC)
        setViewControllers(vcs, animated: false)
    }

    /// Pops back to `GameSetupVC` (the root).
    func quitGame() {
        popToRootViewController(animated: true)
    }
}
