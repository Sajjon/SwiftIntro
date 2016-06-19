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
    }
}

//MARK: IBAction Methods
extension GameOverVC {

    @IBAction func restartButtonPressed(sender: UIButton) {
        performSegueWithIdentifier(restartSeque, sender: self)
    }

    @IBAction func quitButtonPressed(sender: UIButton) {
        performSegueWithIdentifier(quitSeque, sender: self)
    }
}

//MARK: Private Methods
private extension GameOverVC {

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