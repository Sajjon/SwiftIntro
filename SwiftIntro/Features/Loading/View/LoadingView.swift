//
//  LoadingView.swift
//  SwiftIntro
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import UIKit

/// Displays a "Loading…" spinner while data is being fetched, or an error message
/// with a retry button when the API call fails.
///
/// Call `render(_:)` with the latest `LoadingViewModel.Phase` to update the visible state.
/// `onRetry` is invoked when the player taps the retry button.
final class LoadingView: UIView {
    /// Displays the localised "Loading…" string.
    private let loadingLabel = UILabel()

    /// Spins while data is being fetched and images are cached.
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    /// Describes the failure to the player.
    private let errorLabel = UILabel()

    /// Triggers a new fetch attempt after a failure.
    private let retryButton = UIButton(type: .system)

    /// Invoked when the player taps "Retry".
    var onRetry: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupLayout()
        // Start in the loading state.
        setLoadingVisible(true)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }
}

// MARK: - Internal

extension LoadingView {
    /// Updates the view to match `phase`.
    func render(_ phase: LoadingViewModel.Phase) {
        switch phase {
        case .initial:
            logApp.trace("LoadingView -> phase: initial => NOOP")
        case .loading:
            setLoadingVisible(true)
        case .failed:
            setLoadingVisible(false)
        }
    }
}

// MARK: - Private

private extension LoadingView {
    /// Shows the loading stack and hides the error stack, or vice versa.
    func setLoadingVisible(_ loading: Bool) {
        activityIndicator.isHidden = !loading
        loadingLabel.isHidden = !loading
        if loading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        errorLabel.isHidden = loading
        retryButton.isHidden = loading
    }

    func setupLayout() {
        configureSubviews()
        let stack = makeStack()
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -32),
        ])
    }

    func configureSubviews() {
        loadingLabel.text = String(localized: .Loading.loading)
        loadingLabel.textAlignment = .center

        errorLabel.text = String(localized: .Loading.loadFailed)
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0

        retryButton.setTitle(String(localized: .Loading.retry), for: .normal)
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
    }

    func makeStack() -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [
            loadingLabel,
            activityIndicator,
            errorLabel,
            retryButton,
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }

    @objc func retryTapped() {
        onRetry?()
    }
}
