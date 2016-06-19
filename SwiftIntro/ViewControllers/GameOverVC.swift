//
//  GameOverVC.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 18/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import UIKit

private let restartSeque = "restartSegue"
private let quitSeque = "quitSegue"
class GameOverVC: UIViewController, Configurable {

    @IBOutlet weak var gameOverLabel: UILabel!
    @IBOutlet weak var clickCountLabel: UILabel!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var quitButton: UIButton!

    var config: GameConfiguration!
    var result: GameResult!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        guard var configurable = segue?.destinationViewController as? Configurable else { return }
        configurable.config = config
        guard let gameVC = segue?.destinationViewController as? GameVC else { return }
        guard let cards = result.cards else { return }
        unflipCards(cards)
        gameVC.memoryCards = cards
    }
}

//MARK: Private Methods
private extension GameOverVC {

    private func unflipCards(cards: [CardModel]) {
        for card in cards {
            card.flipped = false
        }
    }

    private func setupViews() {
        setupLocalizedText()
    }

    private func setupLocalizedText() {
        gameOverLabel.setLocalizedText("GameOver")
        clickCountLabel.setLocalizedText("ClickCountUnformatted", args: result.clickCount)
        restartButton.setLocalizedTitle("Restart")
        quitButton.setLocalizedTitle("Quit")
    }
}