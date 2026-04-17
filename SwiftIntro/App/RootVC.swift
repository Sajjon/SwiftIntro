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
///     Boot → GameSetupVC → LoadingVC → GameVC<N> → GameOverVC → GameSetupVC
///
/// All navigator protocols are implemented here so that individual view
/// controllers stay navigation-agnostic — they call a protocol method and
/// never touch the navigation stack directly.
final class RootVC: UINavigationController {
    init() {
        logNav.debug("RootVC initializing — GameSetupVC will be root")
        let gameSetupVC = GameSetupVC()
        super.init(rootViewController: gameSetupVC)
        isNavigationBarHidden = true
        gameSetupVC.navigator = self
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
        pushViewController(loadingVC, animated: true)
    }
}

// MARK: - LoadingNavigatorProtocol

extension RootVC: LoadingNavigatorProtocol {
    /// Replaces `LoadingVC` with `GameVC<N>` so the player cannot back-swipe to the loading screen.
    func navigateToGame(_ game: AnyPreparedGame) {
        logNav
            .info(
                "Replacing LoadingVC with GameVC — level: \(game.config.level), cards: \(game.cardCount)"
            )
        let gameVC = makeGameVC(from: game)
        var vcs = viewControllers
        guard !vcs.isEmpty else {
            logNav.error("navigateToGame: navigation stack is empty — cannot replace last VC")
            return
        }
        vcs[vcs.count - 1] = gameVC
        setViewControllers(vcs, animated: false)
    }
}

// MARK: - GameNavigatorProtocol

extension RootVC: GameNavigatorProtocol {
    /// Pushes `GameOverVC` after the final flip animation completes.
    func navigateToGameOver(outcome: AnyGameOutcome) {
        logNav.info("Pushing GameOverVC — clicks: \(outcome.clickCount), level: \(outcome.level)")
        let config = GameConfiguration(level: outcome.level)
        let gameOverVC = GameOverVC(config: config, outcome: outcome)
        gameOverVC.navigator = self
        pushViewController(gameOverVC, animated: true)
    }
}

// MARK: - GameOverNavigatorProtocol

extension RootVC: GameOverNavigatorProtocol {
    /// Replaces `GameOverVC` + `GameVC` with a new `GameVC` reusing the same deck in its existing order.
    func restartGame(_ game: AnyPreparedGame) {
        logNav.info("Restarting game — replacing GameOverVC + GameVC with a fresh GameVC (same images, same order)")
        let gameVC = makeGameVC(from: game)
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

// MARK: - Private

private extension RootVC {
    // swiftlint:disable function_body_length

    /// Dispatches on the `AnyPreparedGame` case to construct the matching `GameVC<N>`,
    /// supplying the `wrapOutcome` closure that re-erases `GameOutcome<N>` back into
    /// `AnyGameOutcome` at game-over time. The body is a pure 3-case dispatch, so
    /// splitting it into per-level helpers would only add indirection.
    func makeGameVC(from game: AnyPreparedGame) -> UIViewController {
        let vc: UIViewController
        switch game {
        case let .easy(g):
            let gameVC = GameVC<6>(g, wrapOutcome: AnyGameOutcome.easy)
            gameVC.navigator = self
            vc = gameVC
        case let .normal(g):
            let gameVC = GameVC<12>(g, wrapOutcome: AnyGameOutcome.normal)
            gameVC.navigator = self
            vc = gameVC
        case let .hard(g):
            let gameVC = GameVC<20>(g, wrapOutcome: AnyGameOutcome.hard)
            gameVC.navigator = self
            vc = gameVC
        }
        return vc
    }

    // swiftlint:enable function_body_length
}
