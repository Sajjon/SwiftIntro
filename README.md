[![codecov](https://codecov.io/gh/Sajjon/SwiftIntro/branch/main/graph/badge.svg?token=siapXgVmia)](https://codecov.io/gh/Sajjon/SwiftIntro/tree/main)

# 📱 My first Memory 🤔💭
#### _An introduction to iOS development with Swift._

A memory game implementation fetching images from Wikimedia. This project aims to introduce you to iOS development with Swift disregarding of your current skill level.

> **Architecture & design decisions:** [DESIGN.md](DESIGN.md)
> **AI assistant instructions:** [CLAUDE.md](CLAUDE.md)

# Challenges
## UIKit
### Improvements
#### Subclassing
10 years ago SwiftIntro used InterfaceBuilder, part of refresh done mid April 2026 the creation of views was converted to programmatic declarations. 

We create lots of UIStackViews with similar code, we can DRY-up this code using a View superclass, subclassed by each view. This also introduces an opportunity to log the UIKit lifecycles. We might benefit from a Never type `interfaceBuilderNotUsed: Never` in `required init?(coder _: NSCoder)`

There might be benefits from subclassing of UIViewControllers too, at least as a scaffolding of UIKit lifecycle events.

### Modernize UIKit
This repo is from June 1st, 2016, using **iOS 9.3**. A lot has happened to UIKit since then. 

#### iOS 13 updates
iOS 13 was released in 2019, 3 years after this repo was originally created.

##### `UIAction`
[`UIAction`](https://developer.apple.com/documentation/uikit/uiaction) allows us to remove `#selector`:
```diff
-restartButton.addTarget(self, action: #selector(restartTapped), for: .touchUpInside)
+restartButton.addAction(
+	UIAction { [weak self] _ in self?.onRestart?() },
+	for: .touchUpInside
+)
```

and:
```diff
-levelSegmentedControl.addTarget(self, action: #selector(changedLevel(_:)), for: .valueChanged)
+levelSegmentedControl.addAction(
+	UIAction { [weak self] action in
+		guard let control = action.sender as? UISegmentedControl else { return }
+		self?.config.level = Level(segmentedControlIndex: control.selectedSegmentIndex)
+	},
+	for: .valueChanged
+)
```

##### `UICollectionViewCompositionalLayout`
We can drastically simplify logic in `MemoryDataSourceAndDelegate` if we
```diff
-    let collectionView: UICollectionView = {
-        let layout = UICollectionViewFlowLayout()
-        // Uniform spacing between rows and between columns.
-        layout.minimumLineSpacing = 8
-        layout.minimumInteritemSpacing = 8
-        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
-        cv.backgroundColor = .black
-        cv.translatesAutoresizingMaskIntoConstraints = false
-        return cv
-    }()
+    let collectionView: UICollectionView
 
-    override init(frame: CGRect) {
-        super.init(frame: frame)
+    /// - Parameter level: The board level — determines the row/column count for the layout.
+    init(level: Level) {
+        collectionView = {
+            let cv = UICollectionView(
+                frame: .zero,
+                collectionViewLayout: GameView.makeLayout(
+                    rows: level.rowCount,
+                    columns: level.columnCount
+                )
+            )
+            cv.backgroundColor = .black
+            cv.translatesAutoresizingMaskIntoConstraints = false
+            return cv
+        }()
+        super.init(frame: .zero)
         backgroundColor = .black
         setupLayout()
     }
```

and then:
```swift
/// Builds a compositional layout whose items are square cards filling the grid exactly.
///
/// Uses the section-provider form so the layout can read the container's actual pixel
/// dimensions at invalidation time and compute absolute card sizes — preserving the
/// square-card invariant without a `UICollectionViewDelegateFlowLayout` delegate.
static func makeLayout(rows: Int, columns: Int) -> UICollectionViewCompositionalLayout {
    UICollectionViewCompositionalLayout { _, environment in
        ... 
    }
}
```

which allows us to:
```diff
private extension MemoryDataSourceAndDelegate {
-    func calculateCardSize(
-        _ flowLayout: UICollectionViewFlowLayout,
-        collectionView: UICollectionView
-    ) -> CGSize {...}

-    func calculateMinimumHeight(
-        _ flowLayout: UICollectionViewFlowLayout,
-        collectionView: UICollectionView
-    ) -> CGFloat {...}

-   func calculateMinimumWidth(
-       _ flowLayout: UICollectionViewFlowLayout,
-       collectionView: UICollectionView
-   ) -> CGFloat {...}
}

-extension MemoryDataSourceAndDelegate: UICollectionViewDelegateFlowLayout {
-    func collectionView(
-        _: UICollectionView,
-        layout collectionViewLayout: UICollectionViewLayout,
-        insetForSectionAt _: Int
-    ) -> UIEdgeInsets {...}
-
-    func collectionView(
-        _ collectionView: UICollectionView,
-        layout collectionViewLayout: UICollectionViewLayout,
-        sizeForItemAt _: IndexPath
-    ) -> CGSize {...}
-}

```

#### iOS 15 updates
> iOS 15 was released 2021

##### `UIButton.Configuration`
[`UIButton.Configuration`](https://developer.apple.com/documentation/uikit/uibutton/configuration-swift.struct) makes buttons more declarative, more consistent, and easier to update correctly as state and design change
```diff
 final class CircularButton: UIButton {
-    /// Re-applies `cornerRadius` whenever the button's bounds change (e.g. on first layout pass).
-    override var bounds: CGRect {
-        didSet { layer.cornerRadius = bounds.height / 2 }
-    }
-
     /// - Parameter title: The localized title string for the button.
     init(title: String) {
         super.init(frame: .zero)
-        setTitle(title)
-        backgroundColor = .purple
-        setTitleColor(.white, for: .normal)
-        setTitleColor(.lightGray, for: .highlighted)
         clipsToBounds = true
+        var config = UIButton.Configuration.filled()
+        config.baseBackgroundColor = .purple
+        config.cornerStyle = .capsule
+        config.title = title
+        configuration = config
     }
}
```

## Features

### iOS + iPadOS
#### Tiny (<1minute)
 
1. Change the color ❤️💛💚💙💜 of the start game button.
1. Change the title of the start game button.
1. Change the background color of the cards.
1. Change the duration of the flip card animation.
1. Switch the position of the _Restart_ button with the _Quit_ button.


#### Small

1. Change the flip card animation from using a horizontal flip to a vertical.
1. Change the _Quit_ button title, which currently is a text with the char _X_, to use an SF Symbol image instead. 
1. Set the background of the memory Card to show an image instead of just a color
1. Save the best score (lowest _clickCount_ for each level) a user has scored and present this score in the _GameOverVC_, persisted.
1. It is currently possible for a user to flip a third card while the flip animation of the two previous cards has not yet finished. Address this issue.
1. Create a timer that counts the time for a game session. Display this time in the _GameOverVC_ after the game has finished, you don't need to display it while playing.

#### Medium
1. Display a timer that is counting upwards in the _GameVC_ showing elapsed time since game start.
1. When you press the _Restart_ button from _GameOverVC_ the cards will have the same position as before, this makes it easy to cheat! Your task is to shuffle the cards before restarting the game.  
1. Implement white space handling for the search query textfield.
1. Like Indiana Jones - we really dislike snakes - prevent snakes from being searched on and inform user if they try.
1. Change the feedback message in _GameOverVC_ from _Well done_ to a dynamic title that changes according to how well it went. Some example strings: _Awesome_, _Not sooo bad_, _That was Horrible_, etc. This string should not be directly dependent on only _Level_ or only _clickCount_, but rather..?
1. Make it possible to set the number of cards to a custom number. Currently, the number of cards is determined based on which difficulty level you chose in the GameSetupVC.
1. Enable landscape mode for all views.
1. Fetch the images from another source than Wikimedia, e.g. Unsplash, which requires an API key. Update the project code to **securely** handle API keys and secrets.

### iPadOS
#### Multi-window
Let's add an iPad-only feature where we can see the cards we have already matched in another window.

## Swift techniques
### `@dynamicMemberLookup`
Split immutable values from mutable ones in `GameModel` and use `@dynamicMemberLookup` to make this virtually identical to what we had.

### InlineArray + Value Generics
This is a terrible idea for this project, but interesting Swift exercise to see if we can replace usage of `Array<Card>` (dynamically sized) with a statically sized `InlineArray<N; Card>` - since we are only allowing a certain fixed amount of cards.

### Typed Throws
Upgrade error to typed throws.

# ClaudeIntro
## Hooks
[`growlrrr`](https://github.com/moltenbits/growlrrr) is a neat tool to send notifications easily from Claude's hooks, this allows you to get macOS notifications when Claude needs you to review permissions. Install `grrr` from `growlrrr`. Then `grrr apps add --bundleID com.anthropic.claudefordesktop --appId ClaudeCode`. Allow `ClaudeCode` notifications in macOS.

Edit `~/.claude/settings.json` to allow Claude to notify you on macOS when it asks for permissions
```
{
	"hooks": {
			"PermissionRequest": [
				{
					"matcher": "",
					"hooks": [
						{
							"type": "command",
							"command": "grrr hook notify --appId ClaudeCode --sound none"
						}
					]
				}
			],
			"Stop": [
				{
					"hooks": [
						{
							"type": "command",
							"command": "grrr hook notify --appId ClaudeCode --sound none"
						}
					]
				}
			],
			"Notification": [
				{
					"hooks": [
						{
							"type": "command",
							"command": "grrr hook notify --appId ClaudeCode --sound none"
						}
					]
				}
			],
			"UserPromptSubmit": [
				{
					"hooks": [
						{
							"type": "command",
							"command": "grrr hook dismiss"
						}
					]
				}
			],
	}
}
```
