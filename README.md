# 📱 My first Memory 🤔💭
#### _An introduction to iOS development with Swift._

A memory game implementation fetching images from Wikimedia. This project aims to introduce you to iOS development with Swift disregarding of your current skill level.

> **Architecture & design decisions:** [DESIGN.md](DESIGN.md)
> **AI assistant instructions:** [CLAUDE.md](CLAUDE.md)

# Challenges
## Modernize UIKit
This repo is from June 1st, 2016, using **iOS 9.3**. A lot has happened to UIKit since then. 

### iOS 13 updates

#### `UIAction`
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

#### `UICollectionViewCompositionalLayout`
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

### iOS 15 updates
> iOS 15 was released 2021

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

### Multi-window
Lets add an iPad only feature, where we can see the cards we have already matched, in another window.

## Swift techniques
### `@dynamicMemberLookup`
Split immutable values from mutable ones in `GameModel` and use `@dynamicMemberLookup` to make this virtually identical to what we had.

### Span + Value Generics
### Typed Throws
