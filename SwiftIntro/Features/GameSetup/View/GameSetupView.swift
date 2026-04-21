//
//  GameSetupView.swift
//  SwiftIntro
//
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import UIKit

/// The setup game screen view — collects game configuration from the player before starting.
///
/// Manages its own `GameConfiguration` state internally and calls `onStartGame`
/// when the player taps the start button, passing the fully-built config out to
/// `GameSetupVC` for navigation.
final class GameSetupView: UIView {
    /// Displays the app title at the top of the game setup screen.
    private let titleLabel = UILabel()

    /// Label above the search query text field.
    private let wikimediaQueryLabel = UILabel()

    /// Text field where the player enters the Wikimedia Commons search query.
    private let wikimediaQueryTextField = UITextField()

    /// Label above the difficulty segmented control.
    private let segmentTitleLabel = UILabel()

    /// Lets the player choose Easy, Normal, or Hard; titles are populated in `setupLocalizedStrings()`.
    private let levelSegmentedControl = UISegmentedControl(items: ["", "", ""])

    /// Tapped to begin data loading and start the game.
    private let startGameButton = UIButton(type: .system)

    /// The configuration built from the current control values.
    /// Updated incrementally as the player changes the level segment or text field.
    private var config = GameConfiguration()

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

    /// Attaches `@objc` action handlers to the segmented control and start button.
    func wireTargets() {
        levelSegmentedControl.addTarget(self, action: #selector(changedLevel(_:)), for: .valueChanged)
        startGameButton.addTarget(self, action: #selector(startGameTapped), for: .touchUpInside)
    }

    /// Seeds the controls with the default `GameConfiguration` values on first display.
    func populateViews() {
        wikimediaQueryTextField.text = config.searchQuery
        levelSegmentedControl.selectedSegmentIndex = config.level.segmentedControlIndex
    }

    /// Updates `config.level` when the player changes the segmented control.
    @objc func changedLevel(_ sender: UISegmentedControl) {
        config.level = Level(segmentedControlIndex: sender.selectedSegmentIndex)
        // swiftformat:disable:next redundantSelf
        logGame.debug("Changed difficulty level to \(self.config.level)")
    }

    /// Reads the text field, updates `config.searchQuery` if non-empty, then fires `onStartGame`.
    @objc func startGameTapped() {
        if let query = wikimediaQueryTextField.text, !query.isEmpty {
            config.searchQuery = query
        }
        onStartGame?(config)
    }
}
