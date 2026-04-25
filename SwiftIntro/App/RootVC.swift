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
        logNav.debug("RootVC initializing — GameSetupVC will be root")
        let gameSetupVC = GameSetupVC()
        super.init(rootViewController: gameSetupVC)
        gameSetupVC.navigator = self
        isNavigationBarHidden = true
        logNav.debug("RootVC ready — navigation stack: [GameSetupVC]")
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }
}

// MARK: - GameSetupNavigatorProtocol

extension RootVC: GameSetupNavigatorProtocol {
    /// Pushes the loading screen onto the stack to begin data fetching.
    func navigateToLoading(config: GameConfiguration) {
        logNav.info("Pushing LoadingVC — config: \(config)")
        let loadingVC = LoadingVC(config: config)
        loadingVC.navigator = self
        isNavigationBarHidden = false
        pushViewController(loadingVC, animated: true)
    }
}

// MARK: - LoadingNavigatorProtocol

extension RootVC: LoadingNavigatorProtocol {
    /// Replaces `LoadingVC` with `GameVC` so the player cannot back-swipe to the loading screen.
    func navigateToGame(_ game: PreparedGame) {
        logNav
            .info(
                "Replacing LoadingVC with GameVC — level: \(game.config.level), cards: \(game.cards.count)"
            )
        let gameVC = GameVC(game)
        gameVC.navigator = self
        var vcs = viewControllers
        guard !vcs.isEmpty else {
            logNav.error("navigateToGame: navigation stack is empty — cannot replace last VC")
            return
        }
        vcs[vcs.count - 1] = gameVC
        setViewControllers(vcs, animated: true)
    }
}

// MARK: - GameNavigatorProtocol

extension RootVC: GameNavigatorProtocol {
    /// Pushes `GameOverVC` after the final flip animation completes.
    func navigateToGameOver(outcome: GameOutcome) {
        logNav.info("Pushing GameOverVC — clicks: \(outcome.clickCount), level: \(outcome.level)")
        let gameOverVC = GameOverVC(outcome: outcome)
        gameOverVC.navigator = self
        pushViewController(gameOverVC, animated: true)
    }
}

// MARK: - GameOverNavigatorProtocol

extension RootVC: GameOverNavigatorProtocol {
    /// Replaces `GameOverVC` + `GameVC` with a new `GameVC` reusing the same deck in its existing order.
    ///
    /// The deck is intentionally **not** reshuffled here — reshuffling on restart is left as a challenge
    /// (see "Medium" features in README.md).
    func restartGame(_ game: PreparedGame) {
        logNav.info("Restarting game — replacing GameOverVC + GameVC with a fresh GameVC (same images, same order)")
        let gameVC = GameVC(game)
        gameVC.navigator = self
        var vcs = viewControllers
        guard vcs.count >= 2 else {
            logNav.error("restartGame: navigation stack too shallow — expected at least 2")
            return
        }
        vcs.removeLast(2)
        vcs.append(gameVC)
        setViewControllers(vcs, animated: false)
    }

    /// Pops back to `GameSetupVC` (the root).
    func quitGame() {
        logNav.info("Quitting game — popping to GameSetupVC (root)")
        popToRootViewController(animated: true)
    }
}
