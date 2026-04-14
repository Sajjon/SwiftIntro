//
//  GameOverView.swift
//  SwiftIntro
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import UIKit

/// The game-over screen view — displays the player's score and offers restart or quit actions.
///
/// `onRestart` and `onQuit` closures are wired by `GameOverVC` to keep navigation
/// logic out of the view.
final class GameOverView: UIView {

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let scoreLabel = UILabel()
    private let tryHarderLabel = UILabel()
    private let restartButton = CircularButton(title: L10n.restart)
    private let quitButton = CircularButton(title: L10n.quit)

    /// Called when the player taps "Restart". Wired by `GameOverVC`.
    var onRestart: (() -> Void)?
    /// Called when the player taps "Quit". Wired by `GameOverVC`.
    var onQuit: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupLayout()
        setupLocalizedText()
    }

    required init?(coder: NSCoder) { fatalError() }

    /// Updates model-driven UI — called once by `GameOverVC` after the outcome is known.
    func render(_ outcome: GameOutcome) {
        scoreLabel.setLocalizedText(L10n.clickScore(outcome.clickCount))
    }
}

// MARK: - Private

private extension GameOverView {

    func setupLayout() {
        [titleLabel, subtitleLabel, scoreLabel, tryHarderLabel].forEach {
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }

        restartButton.addTarget(self, action: #selector(restartTapped), for: .touchUpInside)
        quitButton.addTarget(self, action: #selector(quitTapped), for: .touchUpInside)

        // Fix the button dimensions so they remain circular regardless of title length.
        let buttonSize: CGFloat = 80
        restartButton.translatesAutoresizingMaskIntoConstraints = false
        quitButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            restartButton.heightAnchor.constraint(equalToConstant: buttonSize),
            restartButton.widthAnchor.constraint(equalToConstant: buttonSize),
            quitButton.heightAnchor.constraint(equalToConstant: buttonSize),
            quitButton.widthAnchor.constraint(equalToConstant: buttonSize)
        ])

        let buttonStack = UIStackView(arrangedSubviews: [restartButton, quitButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 24
        buttonStack.distribution = .equalSpacing

        let stack = UIStackView(arrangedSubviews: [
            titleLabel, subtitleLabel, scoreLabel, tryHarderLabel, buttonStack
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40)
        ])
    }

    func setupLocalizedText() {
        titleLabel.setLocalizedText(L10n.gameOverTitle)
        subtitleLabel.setLocalizedText(L10n.gameOverSubtitle)
        tryHarderLabel.setLocalizedText(L10n.tryHarder)
    }

    @objc func restartTapped() { onRestart?() }
    @objc func quitTapped() { onQuit?() }
}
