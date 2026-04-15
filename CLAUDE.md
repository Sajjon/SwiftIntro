# Claude Code instructions for SwiftIntro

> Architecture details, design decisions, and type reference: [DESIGN.md](DESIGN.md)

## Project overview

UIKit memory card game using Mobius unidirectional data flow, Factory DI, and Kingfisher image loading. Targets iOS 17+, Xcode 26.1, Swift 6.

## Architecture rules — always follow these

### Mobius loop
- All game state lives in `GameModel`. Never store state in a view or view controller.
- `GameLogic.update` must stay pure — no UIKit, no side effects, no network calls.
- Effects (`GameEffect`) are the only way to trigger animations, timers, and navigation.
- Score and other model-derivable values must be rendered from `GameModel` in `render(_:)`, never via a dedicated effect.
- The loop infrastructure (`MobiusController` + `GameEffectHandler`) is owned by `GameLoop`, not the VC.
- `GameVC` is a pure view — it implements `Connectable` but has no direct reference to `MobiusController` or `GameEffectHandler`.
- Create the loop via `Mobius.loop(...).makeController(from:)` — `MobiusController.init` is internal.

### View / VC split
- All layout and subviews belong in a `*View.swift` file, never in the view controller.
- Every VC must override `loadView()` and assign the custom view class — no `view.addSubview(...)` in `viewDidLoad`.
- View controllers handle: `loadView()`, lifecycle hooks, navigation, and wiring closures. Nothing else.
- Target < 60 lines per VC file.

### Dependency injection
- Use `@Injected(\.keyPath)` property wrappers — never pass dependencies through constructors unless they vary per instance (e.g. `config`, `cards`).
- Consumers reference protocols (`WikimediaClientProtocol`, `HTTPClientProtocol`, `ImageCacheProtocol`), never concrete types.
- Register new services as `.singleton` in `Container+SwiftIntro.swift`.

### Networking
- No `async/await` — use closure callbacks (`done: @escaping (Result<T, Error>) -> Void`).
- Completion closures are called on an arbitrary background queue; always dispatch UI updates via `DispatchQueue.main.async { }`.
- Wikimedia-specific decoding types stay `private` inside `WikimediaClient.swift`.

### Naming
- `CardSingles` — unique cards from the API, no duplicates.
- `CardDuplicates` — shuffled paired deck ready for play.
- Never use the bare name `Cards`.

## Code style

- `final` on all classes that are not designed for subclassing.
- No `NSObject` inheritance unless required by an `@objc` protocol (only `MemoryDataSourceAndDelegate` needs it).
- Prefer `private extension TypeName { }` for grouping private methods over `// MARK: - Private` with mixed access.
- Document every public/internal symbol with `///` doc comments. Non-trivial inline logic gets `//` comments.
- No storyboards or XIBs — all UI is programmatic.

## File organisation

Group files by feature, not by type:

```
Features/Game/Logic/   — GameModel, GameEvent, GameEffect, GameLogic, GameEffectHandler
Features/Game/View/    — GameView, GameHeaderView, CardCVCell, MemoryDataSourceAndDelegate
Features/Game/         — GameVC
Features/Settings/     — SettingsVC, SettingsView, GameConfiguration
Features/Loading/      — LoadingDataVC, LoadingView
Features/GameOver/     — GameOverVC, GameOverView, GameOutcome
Models/                — Card, CardSingles, CardDuplicates, Level
Networking/            — HTTPClient(Protocol), APIClient(Protocol), Router, ImagePrefetcher
Views/                 — Shared reusable views (CircularButton, CellProtocol)
SupportingFiles/       — AppDelegate, SceneDelegate, Container+SwiftIntro, Logger, Extensions
```

Every new file must be added to `SwiftIntro.xcodeproj/project.pbxproj`.

## Key gotchas

- `configureCell` is called from `willDisplay`, not `cellForItemAt` — this ensures Kingfisher is invoked every time a cell re-enters the visible area, not only on first dequeue.
- `GameEffectHandler.currentModel` is pre-seeded with `initialModel` at init time. Do not change this to `nil` — the Mobius loop delivers the first model asynchronously and cells would appear blank otherwise.
- `MobiusController.stop()` and `disconnectView()` must both be called in `viewDidDisappear` to cancel pending `DispatchWorkItem` timers and avoid delivering events to a detached loop.
- `DispatchWorkItem` for the flip-back timer is stored in `flipBackWorkItem` so it can be cancelled when the loop stops.
- The `WikimediaResponse` Decodable types are `private` to `WikimediaClient.swift` — do not make them internal or public.
