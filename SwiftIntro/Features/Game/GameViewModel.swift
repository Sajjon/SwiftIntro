//
//  GameViewModel.swift
//  SwiftIntro
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Factory
import UIKit

/// Owns and evolves the `GameModel` for a single game session.
///
/// The view model is the single source of truth for the game's state. `GameVC` and
/// `GameView` only render snapshots delivered through callbacks — no game state lives
/// in the view layer.
///
/// The flow is straightforward MVVM:
/// - The view calls `cardTapped(at:)` when the player taps a cell.
/// - The view model mutates its `model` and fires the appropriate callbacks
///   (`onModelChanged`, `onFlipCard`, `onNavigateToGameOver`).
/// - Delayed work (the 1-second flip-back timer and the post-win navigation delay) is
///   scheduled through the injected `Clock`, which tests can swap for `ImmediateClock`.
final class GameViewModel {
    typealias OnModelChanged = (GameModel) -> Void
    typealias OnFlipCard = (_ index: Int, _ faceUp: Bool) -> Void
    typealias OnNavigateToGameOver = (GameOutcome) -> Void

    // MARK: - Dependencies

    /// Injected clock — `MainQueueClock` in production, `ImmediateClock` in tests.
    @Injected(\.clock) private var clock

    // MARK: - State

    /// The complete game state. Mutating this triggers `onModelChanged`.
    private var model: GameModel {
        didSet { onModelChanged?(model) }
    }

    /// Cancellable work item for the delayed flip-back timer.
    /// Stored so it can be cancelled when the screen disappears or when a
    /// subsequent non-match schedules a new flip-back.
    private var flipBackWorkItem: DispatchWorkItem?

    /// Cancellable work item for the delayed game-over navigation. Stored so
    /// `stop()` can cancel it if the screen disappears before it fires.
    private var gameOverWorkItem: DispatchWorkItem?

    /// The player's configuration — threaded through into `GameOutcome` so the
    /// restart flow does not have to reconstruct it from `Level` alone.
    private let config: GameConfiguration

    /// The difficulty level for this session — exposed so `GameVC` can size the grid.
    var level: Level {
        config.level
    }

    // MARK: - Callbacks

    /// Fires whenever the model changes — used by `GameView.render(_:)` to update
    /// model-derived UI like the score label.
    var onModelChanged: OnModelChanged?

    /// Fires when a single card needs to animate into the given face direction.
    var onFlipCard: OnFlipCard?

    /// Fires after the player matches the final pair, once the closing flip has had
    /// time to play out.
    var onNavigateToGameOver: OnNavigateToGameOver?

    // MARK: - Init

    init(_ game: PreparedGame) {
        let cards = game.cards.memoryCards.map(CardModel.init)
        config = game.config
        model = GameModel(cards: cards, level: game.config.level)
    }
}

// MARK: - Lifecycle

extension GameViewModel {
    /// Pushes the initial model out so the view can render its starting state.
    func start(
        onModelChanged: @escaping OnModelChanged,
        onFlipCard: @escaping OnFlipCard,
        onNavigateToGameOver: @escaping OnNavigateToGameOver
    ) {
        self.onFlipCard = onFlipCard
        self.onModelChanged = onModelChanged
        self.onNavigateToGameOver = onNavigateToGameOver
        // swiftformat:disable:next redundantSelf
        logGame.notice("Game started — level: \(self.level.debugDescription)")
        onModelChanged(model)
    }

    /// Cancels any pending timers and clears callbacks. Call from `viewDidDisappear`.
    func stop() {
        logGame.debug("GameViewModel stopping — cancelling timers and clearing callbacks")
        flipBackWorkItem?.cancel()
        flipBackWorkItem = nil
        gameOverWorkItem?.cancel()
        gameOverWorkItem = nil
        onModelChanged = nil
        onFlipCard = nil
        onNavigateToGameOver = nil
    }
}

// MARK: - View queries

extension GameViewModel {
    /// Returns whether the card at `index` may currently be selected.
    ///
    /// Matched cards are permanently locked face-up and must not be tappable.
    func canSelectCard(at index: Int) -> Bool {
        !model.cards[index].isMatched
    }

    /// Configures `cell` to reflect the current visual state of the card at `index`.
    ///
    /// Called from `willDisplay` in the data source, which fires whenever a cell
    /// enters the visible area of the collection view.
    func configureCell(
        _ cell: CardCVCell,
        at index: Int
    ) {
        cell.configure(with: model.cards[index])
    }
}

// MARK: - User actions

extension GameViewModel {
    /// Handles a player tap on the card at `index`.
    ///
    /// Validates the tap, then delegates to `applyFlip` to mutate state and fire callbacks.
    func cardTapped(at index: Int) {
        logGame.debug("Card tapped at index \(index)")
        guard index < model.cards.count else {
            // swiftformat:disable:next redundantSelf
            logGame.debug("Tap ignored — index \(index) is out of bounds (card count: \(self.model.cards.count))")
            return
        }
        guard !model.cards[index].isFlipped, !model.cards[index].isMatched else {
            logGame.debug("Tap ignored — card at index \(index) is already flipped or matched")
            return
        }
        applyFlip(at: index)
    }
}

// MARK: - Private

private extension GameViewModel {
    /// Increments the click count, flips the tapped card face-up, then either stores it
    /// as the pending card or evaluates the resulting pair.
    ///
    /// Mutations are applied to a local copy and assigned to `model` exactly once so
    /// observers see a single coherent snapshot per tap rather than several intermediate
    /// states (`clickCount` bump, card flip, pending-index change).
    func applyFlip(at index: Int) {
        var newModel = model
        newModel.clickCount += 1
        newModel.cards[index].isFlipped = true
        guard let pendingIndex = model.pendingCardIndex else {
            newModel.pendingCardIndex = index
            model = newModel
            // swiftformat:disable:next redundantSelf
            logGame.debug("First card flipped @\(index) — waiting for 2nd 🃏 (click #\(self.model.clickCount))")
            onFlipCard?(index, true)
            return
        }
        logGame
            .debug("Second card of pair flipped at index \(index) — evaluating against pending index \(pendingIndex)")
        newModel.pendingCardIndex = nil
        model = newModel
        evaluatePair(index: index, pendingIndex: pendingIndex)
    }

    /// Compares the two face-up cards and either records a match or schedules the
    /// non-matching pair to flip back after a short delay.
    func evaluatePair(
        index: Int,
        pendingIndex: Int
    ) {
        let isMatchingPair = model.isCard(at: index, matchingCardAt: pendingIndex)
        if isMatchingPair {
            logGame.debug("Pair match! Indices \(pendingIndex) and \(index) are the same card")
            handleMatch(index: index, pendingIndex: pendingIndex)
            return
        }
        logGame.debug("No match — scheduling flip-back for indices \(pendingIndex) and \(index)")
        onFlipCard?(index, true)
        scheduleFlipBack(index1: pendingIndex, index2: index)
    }

    /// Marks both cards matched and either flips the second card face-up (intermediate
    /// match) or triggers the game-over flow (final pair).
    ///
    /// Mutations are applied to a local copy and assigned to `model` once so observers
    /// see a single snapshot covering both newly-matched cards and the bumped pair count.
    func handleMatch(
        index: Int,
        pendingIndex: Int
    ) {
        var newModel = model
        newModel.cards[index].isMatched = true
        newModel.cards[pendingIndex].isMatched = true
        newModel.matches += 1
        model = newModel
        // swiftformat:disable redundantSelf
        logGame
            .info(
                "Match confirmed — \(self.model.matches)/\(self.model.totalPairs) pairs found (click #\(self.model.clickCount))"
            )
        // swiftformat:enable redundantSelf
        onFlipCard?(index, true)
        guard model.matches == model.totalPairs else { return }
        triggerGameOver()
    }

    /// Builds the final outcome and schedules navigation so the closing flip animation
    /// has time to play out before the screen swaps.
    func triggerGameOver() {
        // swiftformat:disable redundantSelf
        logGame
            .notice(
                "Game over — all \(self.model.totalPairs) pairs matched in \(self.model.clickCount) clicks (level: \(self.level))"
            )
        // swiftformat:enable redundantSelf
        // Rebuild the deck from image URLs so the game-over screen can restart
        // with the same images in a freshly shuffled order.
        let cards = model.cards.map(\.card)
        let outcome = GameOutcome(
            config: config,
            clickCount: model.clickCount,
            cards: CardDuplicates(reshuffling: cards)
        )
        // Short delay lets the final flip animation complete before navigating away.
        gameOverWorkItem = clock.schedule(after: 1.0) { [weak self] in
            logGame.debug("Firing onNavigateToGameOver callback")
            self?.onNavigateToGameOver?(outcome)
            self?.gameOverWorkItem = nil
        }
    }

    /// Schedules the two non-matching cards to flip back face-down after a 1-second delay.
    /// Any previously-pending flip-back is cancelled first so rapid non-matches cannot
    /// leave orphaned work items that `stop()` can no longer reach.
    func scheduleFlipBack(
        index1: Int,
        index2: Int
    ) {
        flipBackWorkItem?.cancel()
        flipBackWorkItem = clock.schedule(after: 1.0) { [weak self] in
            self?.flipBackCards(index1: index1, index2: index2)
            self?.flipBackWorkItem = nil
        }
    }

    /// Flips both cards face-down once the delayed timer fires.
    ///
    /// Both flag flips are applied to a local copy and assigned to `model` once so
    /// observers don't briefly see a half-updated state with one card face-up and one
    /// card face-down.
    func flipBackCards(
        index1: Int,
        index2: Int
    ) {
        logGame.debug("Flip-back timer fired — returning cards \(index1) and \(index2) face-down")
        var newModel = model
        newModel.cards[index1].isFlipped = false
        newModel.cards[index2].isFlipped = false
        model = newModel
        onFlipCard?(index1, false)
        onFlipCard?(index2, false)
    }
}
