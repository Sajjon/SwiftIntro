//
//  GameSetupView.swift
//  SwiftIntro
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import UIKit

/// The setup game screen view — collects game configuration from the player before starting.
///
/// The view holds no `GameConfiguration` state of its own: when the player taps
/// the start button, the current control values are read and a fresh
/// `GameConfiguration` is built and delivered via `onStartGame`.
final class GameSetupView: UIView {
    /// Displays the app title at the top of the game setup screen.
    private lazy var titleLabel = UILabel()

    /// Label above the search query text field.
    private lazy var wikimediaQueryLabel = UILabel()

    /// Text field where the player enters the Wikimedia Commons search query.
    private lazy var wikimediaQueryTextField = UITextField()

    /// Label above the difficulty segmented control.
    private lazy var segmentTitleLabel = UILabel()

    /// Lets the player choose Easy, Normal, or Hard; titles are populated in `setupLocalizedStrings()`.
    private lazy var levelSegmentedControl = UISegmentedControl(items: ["", "", ""])

    /// Tapped to begin data loading and start the game.
    private lazy var startGameButton = UIButton(type: .system)

    /// Called when the player taps "Start Game". Receives the finalized `GameConfiguration`.
    var onStartGame: ((GameConfiguration) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupLayout()
        setupLocalizedStrings()
        populateViews()
        wireTargets()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }
}

// MARK: - Private

private extension GameSetupView {
    /// Configures controls, builds the vertical stack, and centres it horizontally with insets.
    func setupLayout() {
        configureControls()
        let stack = makeStack()
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
        ])
    }

    /// Applies font, alignment, and keyboard settings to the title label and text field.
    func configureControls() {
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        wikimediaQueryTextField.borderStyle = .roundedRect
        wikimediaQueryTextField.autocorrectionType = .no
        wikimediaQueryTextField.autocapitalizationType = .none
    }

    /// Returns the vertical stack that arranges all controls from top to bottom.
    func makeStack() -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            wikimediaQueryLabel,
            wikimediaQueryTextField,
            segmentTitleLabel,
            levelSegmentedControl,
            startGameButton,
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }

    /// Fills all labels and control titles with localised strings, including each
    /// level segment title derived from the corresponding `Level` case.
    func setupLocalizedStrings() {
        titleLabel.text = String(localized: .GameSetup.title)
        wikimediaQueryTextField.placeholder = String(localized: .GameSetup.wikimediaQueryPlaceholder)
        wikimediaQueryLabel.text = String(localized: .GameSetup.wikimediaQuery)
        segmentTitleLabel.text = String(localized: .GameSetup.level)
        startGameButton.setLocalizedTitle(String(localized: .GameSetup.startGame))
        setupLevelSegmentTitles()
    }

    /// Iterates all `Level` cases and applies their localised titles to the segmented control.
    func setupLevelSegmentTitles() {
        for i in 0 ... 2 {
            levelSegmentedControl.setTitle(Level(segmentedControlIndex: i).title, forSegmentAt: i)
        }
    }

    /// Attaches the `@objc` action handler to the start button.
    func wireTargets() {
        startGameButton.addTarget(self, action: #selector(startGameTapped), for: .touchUpInside)
    }

    /// Seeds the controls with the default `GameConfiguration` values on first display.
    func populateViews() {
        let defaults = GameConfiguration()
        wikimediaQueryTextField.text = defaults.searchQuery
        levelSegmentedControl.selectedSegmentIndex = defaults.level.segmentedControlIndex
    }

    /// Reads the current control values and delivers a fresh `GameConfiguration` to `onStartGame`.
    @objc func startGameTapped() {
        let level = Level(segmentedControlIndex: levelSegmentedControl.selectedSegmentIndex)
        let defaults = GameConfiguration()
        let query = wikimediaQueryTextField.text.flatMap { $0.isEmpty ? nil : $0 } ?? defaults.searchQuery
        onStartGame?(GameConfiguration(level: level, searchQuery: query))
    }
}
