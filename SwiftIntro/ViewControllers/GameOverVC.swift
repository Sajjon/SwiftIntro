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


    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var tryHarderLabel: UILabel!
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
        quitButton.layer.cornerRadius = quitButton.frame.height/2
        restartButton.layer.cornerRadius = restartButton.frame.height/2
        setupLocalizedText()
    }

    private func setupLocalizedText() {
        titleLabel.setLocalizedText("Title")
        subtitleLabel.setLocalizedText("SubTitle")
        scoreLabel.setLocalizedText("ClickScore", args: result.clickCount)
        tryHarderLabel.setLocalizedText("TryHarder")
        restartButton.setLocalizedTitle("Restart")
        quitButton.setLocalizedTitle("Quit")
    }
}