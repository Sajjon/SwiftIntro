//
//  GameEffectHandler.swift
//  SwiftIntro
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Factory
import MobiusCore
import UIKit

/// Executes `GameEffect`s — all side effects (animations, timers, navigation) live here.
///
/// `GameEffectHandler` implements `Connectable<GameEffect, GameEvent>`, which is the
/// Mobius contract for the effect-handler side of the loop. The framework calls
/// `connect(_:)` once when the loop starts and provides a `dispatch` closure the
/// handler uses to feed new events (e.g. `.flipBackCards`) back into the loop.
///
/// It also caches the latest `GameModel` so the UIKit data source can ask
/// "can this card be selected?" and "how should this cell look?" without
/// coupling the data source to the Mobius loop directly.
final class GameEffectHandler {
    /// The collection view managed by the game screen.
    /// Held weakly to avoid a retain cycle with the view controller.
    weak var collectionView: UICollectionView?

    /// The difficulty level — used to convert flat card indices into `IndexPath` values.
    private let level: Level

    /// Called on the main thread when the game is won, to trigger navigation.
    var onNavigateToGameOver: ((GameOutcome) -> Void)?

    /// Injected clock — controls how delayed dispatches are scheduled.
    /// `MainQueueClock` in production; `ImmediateClock` in tests.
    @Injected(\.clock) private var clock

    /// Cancellable work item for the delayed flip-back timer.
    /// Stored so it can be cancelled if the loop stops before the delay fires.
    private var flipBackWorkItem: DispatchWorkItem?

    /// The most recent model snapshot, updated on every Mobius loop tick.
    ///
    /// Pre-seeded with the initial model so `configureCell` and `canSelectCard`
    /// work on the very first `willDisplay` call, before the loop's first
    /// asynchronous model delivery arrives.
    private var currentModel: GameModel?

    /// - Parameters:
    ///   - level: The board level, required to map flat indices to `IndexPath`s.
    ///   - initialModel: The starting model, used to configure cells on first display
    ///     before the Mobius loop delivers its first asynchronous model update.
    init(
        level: Level,
        initialModel: GameModel
    ) {
        self.level = level
        currentModel = initialModel
    }

    /// Stores the latest model so closure-based queries from the data source reflect
    /// current game state (flip status, match status).
    func update(with model: GameModel) {
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
    ///
    /// Called from `willDisplay` in the data source, which fires whenever a cell
    /// enters the visible area of the collection view.
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
    typealias Input = GameEffect
    typealias Output = GameEvent

    /// Called once by `MobiusController` when the loop starts.
    ///
    /// - Parameter consumer: The event dispatch closure — call it to send events
    ///   (e.g. `.flipBackCards`) back into the Mobius loop.
    /// - Returns: A `Connection` whose `acceptClosure` handles each incoming effect
    ///   and whose `disposeClosure` cancels any pending timers on teardown.
    func connect(_ consumer: @escaping (GameEvent) -> Void) -> Connection<GameEffect> {
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
        _ effect: GameEffect,
        dispatch: @escaping (GameEvent) -> Void
    ) {
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
        // Cell lookups and animations must run on the main thread.
        onMain { [weak self] in
            guard
                let self,
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
        // The returned work item is stored so stop() can cancel it before the delay fires.
        flipBackWorkItem = clock.schedule(after: 1.0) {
            dispatch(.flipBackCards(index1: index1, index2: index2))
        }
    }

    /// Fires `onNavigateToGameOver` after a short delay so the final flip animation finishes first.
    func handleNavigateToGameOver(outcome: GameOutcome) {
        // Short delay lets the final flip animation complete before navigating away.
        clock.schedule(after: 1.0) { [weak self] in self?.onNavigateToGameOver?(outcome) }
    }

    /// Converts a row-major flat index into a `UICollectionView` `IndexPath`.
    ///
    /// The collection view uses sections for rows and items for columns:
    /// `section = flatIndex / columnCount`, `item = flatIndex % columnCount`.
    func indexPath(for flatIndex: Int) -> IndexPath {
        IndexPath(item: flatIndex % level.columnCount, section: flatIndex / level.columnCount)
    }
}
