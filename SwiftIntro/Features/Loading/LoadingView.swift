//
//  LoadingView.swift
//  SwiftIntro
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import UIKit

/// Displays a localised "Loading…" label and a spinning activity indicator.
///
/// Shown while `LoadingDataVC` fetches images from the API and warms the memory cache.
/// Contains no logic — it simply animates until it is removed from the view hierarchy.
final class LoadingView: UIView {
    /// Displays the localised "Loading…" string.
    private let loadingLabel = UILabel()

    /// Spins while data is being fetched and images are cached.
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }
}

// MARK: - Private

private extension LoadingView {
    func setupLayout() {
        configureSubviews()
        let stack = makeStack()
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    func configureSubviews() {
        loadingLabel.setLocalizedText(L10n.loading)
        loadingLabel.textAlignment = .center
        // Start animating immediately — the indicator is visible as soon as the view appears.
        activityIndicator.startAnimating()
    }

    func makeStack() -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [loadingLabel, activityIndicator])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }
}
