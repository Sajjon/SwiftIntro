//
//  GameHeaderView.swift
//  SwiftIntro
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import UIKit

/// A slim header bar shown at the top of the game screen, displaying the current match score.
///
/// The score label is exposed publicly so `GameView.render(_:)` can update it
/// directly from the Mobius model without routing through a callback.
final class GameHeaderView: UIView {
    /// Displays the number of pairs found out of the total, e.g. "2 / 6".
    let scoreLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        addSubview(scoreLabel)
        NSLayoutConstraint.activate([
            scoreLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            scoreLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            // `greaterThanOrEqual` / `lessThanOrEqual` keeps the label from overflowing
            // on small screens while still allowing it to expand to fit longer strings.
            scoreLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 8),
            scoreLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8),
        ])
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }
}
