//
//  CircularButton.swift
//  SwiftIntro
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import UIKit

/// A fixed-size, pill-shaped `UIButton` with a purple background.
///
/// The circular shape is maintained by updating `layer.cornerRadius` whenever `bounds` changes,
/// so the button stays round regardless of how Auto Layout sizes it.
final class CircularButton: UIButton {

    /// Re-applies `cornerRadius` whenever the button's bounds change (e.g. on first layout pass).
    override var bounds: CGRect {
        didSet { layer.cornerRadius = bounds.height / 2 }
    }

    /// - Parameter title: The localized title string for the button.
    init(title: String) {
        super.init(frame: .zero)
        setTitle(title)
        backgroundColor = .purple
        setTitleColor(.white, for: .normal)
        setTitleColor(.lightGray, for: .highlighted)
        // `clipsToBounds = true` ensures the layer's corner radius actually clips
        // the background colour to the circular shape.
        clipsToBounds = true
    }

    required init?(coder: NSCoder) { fatalError() }
}
