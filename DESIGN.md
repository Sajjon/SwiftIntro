# Architecture & Design

> For project setup and tasks, see [README.md](README.md).

## Table of contents

- [Overview](#overview)
- [Unidirectional data flow — Mobius](#unidirectional-data-flow--mobius)
- [Feature folder structure](#feature-folder-structure)
- [Thin view controllers](#thin-view-controllers)
- [Dependency injection — Factory](#dependency-injection--factory)
- [Networking stack](#networking-stack)
- [Image caching](#image-caching)
- [Key types at a glance](#key-types-at-a-glance)
- [Data flow walkthrough](#data-flow-walkthrough)
- [Design decisions](#design-decisions)

---

## Overview

SwiftIntro is a UIKit memory card game. It fetches images from the Wikimedia Commons API and uses them as card faces on a grid whose size is determined by the chosen difficulty level.

The codebase is structured around three principles:

1. **Unidirectional data flow** via [Mobius.swift](https://github.com/spotify/Mobius.swift) — all state lives in one immutable `GameModel` snapshot; the UI is a pure function of that snapshot.
2. **Thin view controllers** — every screen's layout and rendering belongs to a dedicated `UIView` subclass; view controllers only manage lifecycle and navigation.
3. **Protocol-oriented dependency injection** via [Factory](https://github.com/hmlongco/Factory) — concrete implementations are never referenced directly by their consumers.

---

## Unidirectional data flow — Mobius

The game screen uses the [Mobius](https://github.com/spotify/Mobius.swift) library to enforce a strict unidirectional loop:

```
 ┌──────────────────────────────────────────────────────────┐
 │                      Mobius Loop                         │
 │                                                          │
 │   GameEvent  ──►  GameLogic.update  ──►  GameModel       │
 │       ▲                │                    │            │
 │       │                ▼                    ▼            │
 │  GameEffectHandler  GameEffect         GameVC.connect    │
 │  (side effects)     (animation,        (render UI)       │
 │                      timer, nav)                         │
 └──────────────────────────────────────────────────────────┘
```

| Type | Role |
|---|---|
| `GameModel` | Immutable snapshot of all game state. Single source of truth. |
| `GameEvent` | Inputs into the loop (card tapped, flip-back timer fired). |
| `GameEffect` | Side-effect instructions produced by `update` (animate, navigate, schedule timer). |
| `GameLogic.update` | Pure function `(GameModel, GameEvent) -> Next<GameModel, GameEffect>`. No state, no UIKit. |
| `GameEffectHandler` | Executes effects: runs animations, manages `DispatchWorkItem` timers, triggers navigation. Implements `Connectable<GameEffect, GameEvent>`. |
| `GameLoop` | Owns `MobiusController` + `GameEffectHandler`. Exposes `start(view:collectionView:onNavigateToGameOver:)` and `stop()` so `GameVC` needs no loop infrastructure. |
| `GameVC` | Pure view — implements `Connectable<GameModel, GameEvent>`. Owns only `GameLoop` and `GameView`. |

### MobiusController

`GameVC` uses `MobiusController` (created via `Mobius.loop(...).makeController(from:)`) rather than a raw `MobiusLoop`. This means the framework manages `start`/`stop` and the view connection — `GameVC` just calls `connectView(self)` and `start()`.

### Why the score is not an effect

The current match count is derived directly from `GameModel.matches` in `GameView.render(_:)`. There is no `notifyMatchFound` effect. Any value computable from the model is rendered from the model — effects are reserved for things the model cannot express (animations, timers, navigation).

---

## Feature folder structure

Source files are grouped by feature, not by type. Each feature folder contains all layers relevant to that screen.

```
SwiftIntro/
├── Features/
│   ├── Game/
│   │   ├── GameVC.swift                   # Lifecycle, Mobius wiring
│   │   ├── Logic/
│   │   │   ├── GameModel.swift            # State + CardModel
│   │   │   ├── GameEvent.swift            # Loop inputs
│   │   │   ├── GameEffect.swift           # Side-effect instructions
│   │   │   ├── GameLogic.swift            # Pure update function
│   │   │   ├── GameEffectHandler.swift    # Effect executor + Connectable
│   │   │   └── GameLoop.swift             # Owns MobiusController + GameEffectHandler
│   │   └── View/
│   │       ├── GameView.swift             # Root view (header + grid)
│   │       ├── GameHeaderView.swift       # Score bar
│   │       ├── CardCVCell.swift           # Individual card cell
│   │       └── MemoryDataSourceAndDelegate.swift
│   ├── Settings/
│   │   ├── SettingsVC.swift
│   │   ├── SettingsView.swift
│   │   └── GameConfiguration.swift
│   ├── Loading/
│   │   ├── LoadingDataVC.swift
│   │   └── LoadingView.swift
│   └── GameOver/
│       ├── GameOverVC.swift
│       ├── GameOverView.swift
│       └── GameOutcome.swift
├── Models/
│   ├── Card.swift                         # Single unique card (imageUrl)
│   ├── CardSingles.swift                  # Unordered set from API
│   ├── CardDuplicates.swift               # Shuffled paired deck for play
│   └── Level.swift                        # Difficulty (grid dimensions)
├── Networking/
│   ├── HTTPClientProtocol.swift
│   ├── HTTPClient.swift                   # URLSession-backed
│   ├── APIClientProtocol.swift
│   ├── APIClient.swift                    # Wikimedia + Codable
│   ├── Router.swift                       # URL construction (URLComponents)
│   └── ImagePrefetcher.swift              # Kingfisher wrapper + protocol
├── Views/
│   ├── CircularButton.swift
│   └── CellProtocol.swift
└── SupportingFiles/
    ├── Container+SwiftIntro.swift         # Factory registrations
    ├── Logger+SwiftIntro.swift
    └── Extensions/
        ├── Array_Extension.swift
        ├── Dispatch+Extensions.swift
        ├── NSObject_Extension.swift
        ├── UIButton_Extension.swift
        ├── UILabel_Extension.swift
        └── UIView_Extension.swift
```

---

## Thin view controllers

Every screen follows the same split:

| File | Responsibility |
|---|---|
| `*VC.swift` | `loadView()`, lifecycle hooks, navigation, wiring closures |
| `*View.swift` | All subviews, Auto Layout constraints, `render(_:)` |

View controllers never add subviews directly. Instead, `loadView()` installs the dedicated view class as `self.view`:

```swift
override func loadView() {
    view = GameView()  // not view.addSubview(...)
}
```

This keeps the VC under ~60 lines in every case and makes views independently testable and reusable.

---

## Dependency injection — Factory

All shared services are registered in `Container+SwiftIntro.swift` as `.singleton` factories and injected at the call site with `@Injected(\.keyPath)`:

```swift
// Registration
extension Container {
    var apiClient: Factory<APIClientProtocol> {
        self { APIClient() }.singleton
    }
}

// Injection
final class LoadingDataVC: UIViewController {
    @Injected(\.apiClient) private var apiClient
}
```

Consumers reference protocols (`APIClientProtocol`, `HTTPClientProtocol`, `ImageCacheProtocol`), never concrete types. This makes every dependency swappable for testing without subclassing or global state.

---

## Networking stack

```
LoadingDataVC
    │ getPhotos(_:done:)
    ▼
APIClient  (@Injected \.apiClient)
    │ httpClient.get(url:done:)
    ▼
HTTPClient  (@Injected \.httpClient)
    │ URLSession.dataTask
    ▼
Wikimedia Commons API  (https://commons.wikimedia.org/w/api.php)
    │ JSON → WikimediaResponse (Decodable, private to APIClient)
    ▼
CardSingles  →  CardDuplicates  →  GameVC
```

- **`Router`** builds `URL`s using `URLComponents` + `URLQueryItem` (handles percent-encoding automatically).
- **`APIClient`** decodes with `Codable`; the `WikimediaResponse` struct is `private` — no Wikimedia types leak beyond the file.
- Namespace `6` (`File:`) is enforced in the query so only media files are returned.
- `isImageURL` filters out PDFs and OGG files, keeping only `.jpg`/`.jpeg`/`.png` URLs that Kingfisher can display.

---

## Image caching

Card images are pre-loaded into the Kingfisher **memory** cache during the loading screen, before the game begins. This prevents any visible lag on the first card flip.

`KingfisherManager.retrieveImage(with:)` (not `ImagePrefetcher`) is used deliberately — Kingfisher's own prefetcher skips images already on disk and leaves them out of the faster memory cache.

A `DispatchGroup` tracks completion across all URLs and calls `done()` on the main queue only once every image has been fetched.

---

## Key types at a glance

| Type | Kind | Description |
|---|---|---|
| `Card` | `struct` | Unique card — `imageUrl: URL` |
| `CardSingles` | `struct` | Unordered unique cards from the API |
| `CardDuplicates` | `struct` | Shuffled paired deck ready for play |
| `CardModel` | `struct` | Card + mutable `isFlipped`/`isMatched` — used in `GameModel` |
| `GameModel` | `struct` | Complete game snapshot (cards, score, pending index) |
| `GameEvent` | `enum` | Loop inputs: `cardTapped`, `flipBackCards` |
| `GameEffect` | `enum` | Side-effect instructions: `flipCard`, `scheduleFlipBack`, `navigateToGameOver` |
| `Level` | `enum` | `easy` / `normal` / `hard` — drives grid dimensions |
| `GameConfiguration` | `struct` | Player-chosen settings: level + search query |
| `GameOutcome` | `struct` | Post-game result: level, click count, deck (for restart) |

---

## Data flow walkthrough

A single card tap from the player's finger to the updated UI:

1. Player taps a cell → `MemoryDataSourceAndDelegate.didSelectItemAt` fires.
2. `canSelectCard?(index)` is called → `GameEffectHandler.canSelectCard(at:)` returns `true` if the card is not already matched.
3. `onCardTapped?(index)` fires → the closure (set in `GameVC.connect(_:)`) calls `consumer(.cardTapped(index:))`.
4. The Mobius loop calls `GameLogic.update(model:event:)` on its internal queue.
5. `update` returns a new `GameModel` (card flipped, click count incremented) and a `.flipCard` effect.
6. The `acceptClosure` in `GameVC.connect` is called with the new model → `effectHandler.update(with:)` caches it, `gameView.render(_:)` updates the score label.
7. `GameEffectHandler.handle(.flipCard(...))` is called → dispatched to the main thread → `CardCVCell.animateFlip(faceUp:)` plays the 0.6 s flip animation.

---

## Design decisions

### No `async/await`

The codebase uses closure-based callbacks throughout. This was a deliberate choice made when the project was created before `async/await` was available, and the pattern has been preserved for consistency and accessibility for junior learners.

### `NSObject` only where required

`MemoryDataSourceAndDelegate` inherits from `NSObject` because `UICollectionViewDataSource` and `UICollectionViewDelegate` are `@objc` protocols that require it. No other class in the project inherits from `NSObject`.

### `CardDuplicates` vs `CardSingles`

Two distinct named types prevent accidentally passing an unduplicated deck to `GameVC` or a duplicated deck to `APIClient`. The type system enforces the contract at the call site.

### `configureCell` in `willDisplay`, not `cellForItemAt`

`willDisplay` fires every time a cell becomes visible, including after reuse. `cellForItemAt` only fires when a cell is first dequeued. Using `willDisplay` ensures Kingfisher re-loads (or cache-hits) the image each time a cell scrolls back into view.

### `currentModel` pre-seeded in `GameEffectHandler`

`MobiusController.start()` delivers the initial model asynchronously. If `currentModel` started as `nil`, `configureCell` would silently no-op on the first `willDisplay` call (before the first model arrives), leaving cards imageless. Pre-seeding `currentModel` with the same initial model passed to the controller avoids this race.
