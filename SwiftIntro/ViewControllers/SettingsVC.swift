//
//  SettingsVC.swift
//  SwiftIntro
//
//  Created by Miriam Tisander on 02/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import Foundation
import UIKit

struct GameConfiguration {
    var level: Level = .Normal
    var username: String = "netlightconsulting"
}

protocol Configurable {
    var config: GameConfiguration! {get set}
}

private let startGameSegue = "startGameSegue"
class SettingsVC: UIViewController, Configurable {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var levelSegmentedControl: UISegmentedControl!
    @IBOutlet weak var startGameButton: UIButton!
    
    var config: GameConfiguration!

    required init?(coder aDecoder: NSCoder) {
        self.config = GameConfiguration()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        populateViews()
    }

    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {

        guard let identifier = segue?.identifier else { return }
        guard identifier == startGameSegue else { return }
        guard let vc = segue?.destinationViewController as? GameVC else { return }

        if let username: String = usernameTextField.text where !username.isEmpty{
            config.username = username
        }

        vc.config = config
    }

    @IBAction func changedLevel(sender: UISegmentedControl) {
        let level = Level(segmentedControlIndex: sender.selectedSegmentIndex)
        config.level = level
    }
}

private extension SettingsVC {

    private func setupViews() {
        setupLocalizableStrings()
        startGameButton.layer.cornerRadius = startGameButton.frame.size.height/2
    }

    private func populateViews() {
        usernameTextField.text = config.username
        levelSegmentedControl.selectedSegmentIndex = config.level.segmentedControlIndex
    }

    private func setupLocalizableStrings() {
        usernameTextField.placeholder = localizedString("Username")
        setupLocalizationForSegmentedControl()
        usernameLabel.setLocalizedText("Username")
        startGameButton.setLocalizedTitle("StartGame")
    }

    private func setupLocalizationForSegmentedControl() {
        for i in 0...2 {
            let level = Level(segmentedControlIndex: i)
            let title = level.title
            levelSegmentedControl.setTitle(title, forSegmentAtIndex: i)
        }
    }
}
