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
/// `GameLoop` groups `MobiusController` and `GameEffectHandler` so that `GameVC`
/// can remain a pure view — it implements `Connectable` but knows nothing about
/// loop infrastructure. Create one `GameLoop` per game session and discard it when
/// the session ends.
final class GameLoop {
    /// Handles all side effects: flip animations, the flip-back timer, and game-over navigation.
    private let effectHandler: GameEffectHandler

    /// The Mobius loop controller — drives the `update → effect → event` cycle.
    private let controller: MobiusController<GameModel, GameEvent, GameEffect>

    /// Builds the complete Mobius loop from the given initial model.
    ///
    /// `effectHandler` is pre-seeded with `initialModel` so cell configuration works
    /// on the very first `willDisplay` call, before the loop's first async model delivery.
    init(initialModel: GameModel) {
        let effectHandler = GameEffectHandler(initialModel: initialModel)
        self.effectHandler = effectHandler
        controller = Mobius
            .loop(update: GameLogic.update, effectHandler: effectHandler)
            .makeController(from: initialModel)
    }
}

// MARK: Computed Properties

extension GameLoop {
    /// The difficulty level for this session — exposed so `GameVC` can size the grid
    /// without storing `GameConfiguration` or `CardDuplicates` separately.
    var level: Level {
        effectHandler.level
    }
}

extension GameLoop {
    /// Connects the view to the loop, wires the effect handler's UIKit dependencies,
    /// and starts the Mobius loop.
    ///
    /// Call this from `viewDidLoad` after the collection view is ready.
    ///
    /// - Parameters:
    ///   - view: The `Connectable` view that renders `GameModel` and dispatches `GameEvent`s.
    ///   - collectionView: The card grid — used by the effect handler to find cells for flip animations.
    ///   - onNavigateToGameOver: Called on the main thread when the player wins.
    func start<View: Connectable>(
        view: View,
        collectionView: UICollectionView,
        onNavigateToGameOver: @escaping (GameOutcome) -> Void
    ) where View.Input == GameModel, View.Output == GameEvent {
        effectHandler.collectionView = collectionView
        effectHandler.onNavigateToGameOver = onNavigateToGameOver
        controller.connectView(view)
        controller.start()
    }

    /// Stops the loop and disconnects the view, cancelling any pending timers.
    ///
    /// Idempotent — safe to call more than once; subsequent calls are no-ops.
    /// Call this from `viewDidDisappear`.
    func stop() {
        guard controller.running else { return }
        controller.stop()
        controller.disconnectView()
    }

    /// Forwards the latest model to the effect handler so `canSelectCard` and
    /// `configureCell` reflect current game state.
    func update(with model: GameModel) {
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
