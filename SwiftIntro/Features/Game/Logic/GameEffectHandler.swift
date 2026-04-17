//
//  GameEffectHandler.swift
//  SwiftIntro
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Factory
import MobiusCore
import UIKit

/// Executes `GameEffect<N>`s — all side effects (animations, timers, navigation) live here.
///
/// Generic over the compile-time card count `N`, so that the cached `GameModel<N>` and
/// the outcome carried by `.navigateToGameOver` are all sized consistently.
final class GameEffectHandler<let N: Int> {
    /// The collection view managed by the game screen.
    /// Held weakly to avoid a retain cycle with the view controller.
    weak var collectionView: UICollectionView?

    /// The difficulty level — used to convert flat card indices into `IndexPath` values.
    let level: Level

    /// Called when the game is won, to trigger navigation.
    ///
    /// Takes a concrete `GameOutcome<N>`; the owning `GameVC<N>` is responsible for
    /// wrapping it into an `AnyGameOutcome` before handing it to the navigator.
    var onNavigateToGameOver: ((GameOutcome<N>) -> Void)?

    /// Injected clock — controls how delayed dispatches are scheduled.
    /// `MainQueueClock` in production; `ImmediateClock` in tests.
    @Injected(\.clock) private var clock

    /// Cancellable work item for the delayed flip-back timer.
    private var flipBackWorkItem: DispatchWorkItem?

    /// The most recent model snapshot, updated on every Mobius loop tick.
    ///
    /// Pre-seeded with the initial model so `configureCell` and `canSelectCard`
    /// work on the very first `willDisplay` call, before the loop's first
    /// asynchronous model delivery arrives.
    private var currentModel: GameModel<N>?

    init(
        initialModel: GameModel<N>
    ) {
        level = initialModel.level
        currentModel = initialModel
    }

    /// Stores the latest model so closure-based queries from the data source reflect
    /// current game state (flip status, match status).
    func update(with model: GameModel<N>) {
        currentModel = model
    }

    /// Returns whether the card at `index` may be selected by the player.
    ///
    /// Matched cards are permanently locked face-up and must not be tappable.
    func canSelectCard(at index: Int) -> Bool {
        guard let model = currentModel else { return false }
        return !model.cards[index].isMatched
    }

    /// Configures `cell` to reflect the current visual state of the card at `index`.
    func configureCell(
        _ cell: CardCVCell,
        at index: Int
    ) {
        guard let model = currentModel else { return }
        cell.configure(with: model.cards[index])
    }
}

// MARK: - Connectable

extension GameEffectHandler: Connectable {
    typealias Input = GameEffect<N>
    typealias Output = GameEvent

    func connect(_ consumer: @escaping (GameEvent) -> Void) -> Connection<GameEffect<N>> {
        Connection(
            acceptClosure: { [weak self] effect in
                self?.handle(effect, dispatch: consumer)
            },
            disposeClosure: { [weak self] in
                self?.flipBackWorkItem?.cancel()
            }
        )
    }
}

// MARK: - Effect handling

private extension GameEffectHandler {
    /// Routes an incoming effect to the appropriate handler.
    func handle(
        _ effect: GameEffect<N>,
        dispatch: @escaping (GameEvent) -> Void
    ) {
        logGame.debug("Handling effect: \(effect)")
        switch effect {
        case let .flipCard(index, faceUp):
            handleFlipCard(index: index, faceUp: faceUp)
        case let .scheduleFlipBack(index1, index2):
            handleScheduleFlipBack(index1: index1, index2: index2, dispatch: dispatch)
        case let .navigateToGameOver(outcome):
            handleNavigateToGameOver(outcome: outcome)
        }
    }

    /// Animates the card at `index` to the given face direction on the main thread.
    func handleFlipCard(
        index: Int,
        faceUp: Bool
    ) {
        logGame.debug("Animating card \(index) face \(faceUp ? "up" : "down")")
        DispatchQueue.main.async { [weak self] in
            guard let self,
                  let cell = collectionView?.cellForItem(at: indexPath(for: index)) as? CardCVCell
            else { return }
            cell.animateFlip(faceUp: faceUp)
        }
    }

    /// Schedules a `.flipBackCards` event after a 1-second delay using a cancellable `DispatchWorkItem`.
    func handleScheduleFlipBack(
        index1: Int,
        index2: Int,
        dispatch: @escaping (GameEvent) -> Void
    ) {
        logGame.debug("Scheduling flip-back for cards \(index1) and \(index2) after 1 s")
        flipBackWorkItem = clock.schedule(after: 1.0) {
            dispatch(.flipBackCards(index1: index1, index2: index2))
        }
    }

    /// Fires `onNavigateToGameOver` after a short delay so the final flip animation finishes first.
    func handleNavigateToGameOver(outcome: GameOutcome<N>) {
        logGame.info("Final flip complete — scheduling navigation to game-over screen after 1 s delay")
        clock.schedule(after: 1.0) { [weak self] in
            logGame.debug("Firing onNavigateToGameOver callback")
            self?.onNavigateToGameOver?(outcome)
        }
    }

    /// Converts a row-major flat index into a `UICollectionView` `IndexPath`.
    func indexPath(for flatIndex: Int) -> IndexPath {
        IndexPath(
            item: flatIndex % level.columnCount,
            section: flatIndex / level.columnCount
        )
    }
}
