//
//  SettingsVC.swift
//  SwiftIntro
//
//  Created by Miriam Tisander on 02/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import Foundation
import UIKit

enum Level {
    case Easy, Normal, Hard

  var nbrOfCards: Int{
        return self.rowCount*self.columnCount
    }

    var title: String {
        let localizedKey: String
        switch self {
        case .Easy:
            localizedKey = "Easy"
        case .Normal:
            localizedKey = "Normal"
        case .Hard:
            localizedKey = "Hard"
        }
        let title = localizedString(localizedKey)
        return title
    }
    
    var columnCount: Int{
        switch self {
        case .Easy:
            return 2
        case .Normal:
            return 3
        case .Hard:
            return 4
        }
    }
    
    var rowCount: Int{
        switch self {
        case .Easy:
            return 3
        case .Normal:
            return 4
        case .Hard:
            return 5
        }
    }
}

struct GameSettings {
    var level: Level = .Normal
    var username: String = "netlightconsulting"
}

class SettingsVC: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var levelSegmentedControl: UISegmentedControl!
    @IBOutlet weak var startGameButton: UIButton!
    
    var settings: GameSettings = GameSettings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if let username: String = usernameTextField.text where !username.isEmpty{
            settings.username = username
        }

        if segue?.identifier == "startGameSegue" {
            if let vc = segue?.destinationViewController as? GameVC {
                vc.gameSettings = settings
            }
            
        }
    }

    @IBAction func changedLevel(sender: UISegmentedControl) {
        let level = levelAtIndex(sender.selectedSegmentIndex)
        settings.level = level
    }
}

private extension SettingsVC {

    private func levelAtIndex(index: Int) -> Level {
        let level: Level
        switch index {
        case 0:
        level = .Easy
        case 1:
        level = .Normal
        case 2:
        level = .Hard
        default:
            fatalError("Should not be possible")
        }
        return level

    }

    private func setupViews() {
        setupLocalizableStrings()
    }

    private func setupLocalizableStrings() {
        setupLocalizationForSegmentedControl()
        usernameLabel.setLocalizedText("Username")
        startGameButton.setLocalizedTitle("StartGame")
    }

    private func setupLocalizationForSegmentedControl() {
        for i in 0...2 {
            let title = levelAtIndex(i).title
            levelSegmentedControl.setTitle(title, forSegmentAtIndex: i)
        }
    }
}
