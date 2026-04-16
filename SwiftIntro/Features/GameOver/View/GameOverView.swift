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
    /// Displays the game-over title (e.g. "Game Over!").
    private let titleLabel = UILabel()

    /// Displays a congratulatory subtitle.
    private let subtitleLabel = UILabel()

    /// Shows the player's click count for this session.
    private let scoreLabel = UILabel()

    /// Encourages the player to beat their score next time.
    private let tryHarderLabel = UILabel()

    /// Triggers a new game with the same images shuffled.
    private let restartButton = CircularButton(title: String(localized: .GameOver.restart))

    /// Returns the player to the settings screen.
    private let quitButton = CircularButton(title: String(localized: .GameOver.quit))

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

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    /// Updates model-driven UI — called once by `GameOverVC` after the outcome is known.
    func render(_ outcome: GameOutcome) {
        scoreLabel.text = String(localized: .GameOver.clickScore(score: outcome.clickCount))
    }
}

// MARK: - Private

private extension GameOverView {
    /// Configures labels and buttons, builds the stack hierarchy, and activates centering constraints.
    func setupLayout() {
        configureLabels()
        configureButtons()
        let stack = makeMainStack(buttonStack: makeButtonStack())
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
        ])
    }

    /// Sets shared text alignment and multi-line wrapping on all score and status labels.
    func configureLabels() {
        for item in [titleLabel, subtitleLabel, scoreLabel, tryHarderLabel] {
            item.textAlignment = .center
            item.numberOfLines = 0
        }
    }

    /// Wires tap targets for the restart and quit buttons and fixes their circular dimensions.
    func configureButtons() {
        restartButton.addTarget(self, action: #selector(restartTapped), for: .touchUpInside)
        quitButton.addTarget(self, action: #selector(quitTapped), for: .touchUpInside)
        constrainButtonSizes(to: 80)
    }

    /// Fixes both buttons to an explicit `size × size` square so they stay perfectly circular.
    func constrainButtonSizes(to size: CGFloat) {
        // Fix the button dimensions so they remain circular regardless of title length.
        restartButton.translatesAutoresizingMaskIntoConstraints = false
        quitButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            restartButton.heightAnchor.constraint(equalToConstant: size),
            restartButton.widthAnchor.constraint(equalToConstant: size),
            quitButton.heightAnchor.constraint(equalToConstant: size),
            quitButton.widthAnchor.constraint(equalToConstant: size),
        ])
    }

    /// Returns a horizontal stack containing the restart and quit buttons.
    func makeButtonStack() -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [restartButton, quitButton])
        stack.axis = .horizontal
        stack.spacing = 24
        stack.distribution = .equalSpacing
        return stack
    }

    /// Returns the root vertical stack that centres all labels above the button row.
    func makeMainStack(buttonStack: UIStackView) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel, subtitleLabel, scoreLabel, tryHarderLabel, buttonStack,
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }

    /// Applies localised strings to the title, subtitle, and encouragement labels.
    func setupLocalizedText() {
        titleLabel.text = String(localized: .GameOver.gameOverTitle)
        subtitleLabel.text = String(localized: .GameOver.gameOverSubtitle)
        tryHarderLabel.text = String(localized: .GameOver.tryHarder)
    }

    /// Forwards the restart tap to `onRestart`.
    @objc func restartTapped() {
        onRestart?()
    }

    /// Forwards the quit tap to `onQuit`.
    @objc func quitTapped() {
        onQuit?()
    }
}
