//
//  GameOverVC.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 18/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import UIKit

class GameOverVC: UIViewController {

    @IBOutlet weak var gameOverLabel: UILabel!
    @IBOutlet weak var clickCountLabel: UILabel!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var quitButton: UIButton!

    var settings: GameSettings!
    var gameResult: GameResult!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
}

//MARK: IBAction Methods
extension GameOverVC {

    @IBAction func restartButtonPressed(sender: UIButton) {
    }
    @IBAction func quitButtonPressed(sender: UIButton) {
    }
}

//MARK: Private Methods
private extension GameOverVC {

    private func setupViews() {
        setupLocalizedText()
    }

    private func setupLocalizedText() {
        gameOverLabel.setLocalizedText("GameOver")
        clickCountLabel.setLocalizedText("ClickCountUnformatted", args: gameResult.clickCount)
        restartButton.setLocalizedTitle("Restart")
        quitButton.setLocalizedTitle("Quit")
    }
}