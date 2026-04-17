//
//  GameLoop.swift
//  SwiftIntro
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import MobiusCore
import UIKit

/// Owns and manages the full Mobius loop for a single game session.
///
/// `GameLoop` groups `MobiusController<GameModel<N>, GameEvent, GameEffect<N>>` and
/// `GameEffectHandler<N>` so `GameVC<N>` can remain a pure view.
final class GameLoop<let N: Int> {
    private let effectHandler: GameEffectHandler<N>

    private let controller: MobiusController<GameModel<N>, GameEvent, GameEffect<N>>

    /// Builds the complete Mobius loop from the given initial model.
    init(initialModel: GameModel<N>) {
        logGame.debug("GameLoop initializing — level: \(initialModel.level), pairs: \(initialModel.totalPairs)")
        let effectHandler = GameEffectHandler<N>(initialModel: initialModel)
        self.effectHandler = effectHandler
        controller = Mobius
            .loop(update: GameLogic.update, effectHandler: effectHandler)
            .makeController(from: initialModel)
    }
}

// MARK: Computed Properties

extension GameLoop {
    /// The difficulty level for this session.
    var level: Level {
        effectHandler.level
    }
}

extension GameLoop {
    /// Connects the view to the loop, wires the effect handler's UIKit dependencies,
    /// and starts the Mobius loop.
    func start<View: Connectable>(
        view: View,
        collectionView: UICollectionView,
        onNavigateToGameOver: @escaping (GameOutcome<N>) -> Void
    ) where View.Input == GameModel<N>, View.Output == GameEvent {
        logGame.debug("GameLoop starting — connecting view and effect handler")
        effectHandler.collectionView = collectionView
        effectHandler.onNavigateToGameOver = onNavigateToGameOver
        controller.connectView(view)
        controller.start()
        logGame.debug("Mobius loop is running")
    }

    /// Stops the loop and disconnects the view, cancelling any pending timers.
    func stop() {
        guard controller.running else {
            logGame.debug("GameLoop.stop() called but loop is not running — skipping")
            return
        }
        logGame.debug("GameLoop stopping — cancelling pending timers and disconnecting view")
        controller.stop()
        controller.disconnectView()
    }

    /// Forwards the latest model to the effect handler.
    func update(with model: GameModel<N>) {
        effectHandler.update(with: model)
    }

    /// Returns whether the card at `index` may currently be selected.
    func canSelectCard(at index: Int) -> Bool {
        effectHandler.canSelectCard(at: index)
    }

    /// Configures `cell` to match the current visual state of the card at `index`.
    func configureCell(
        _ cell: CardCVCell,
        at index: Int
    ) {
        effectHandler.configureCell(cell, at: index)
    }
}
