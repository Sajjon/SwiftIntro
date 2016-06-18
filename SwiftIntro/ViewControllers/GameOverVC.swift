//
//  GameOverVC.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 18/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import UIKit

class GameOverVC: UIViewController {

    @IBOutlet weak var clickCountLabel: UILabel!

    var gameResult: GameResult!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
}

//MARK: Private Methods
private extension GameOverVC {

    private func setupViews() {
        clickCountLabel.setLocalizedText("ClickCountUnformatted", args: gameResult.clickCount)
    }
}