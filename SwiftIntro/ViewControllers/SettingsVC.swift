//
//  SettingsVC.swift
//  SwiftIntro
//
//  Created by Miriam Tisander on 02/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import Foundation
import UIKit

public protocol GameLevel {
    var rowCount: Int { get }
    var columnCount: Int { get }
    var nbrOfCards: Int { get }
}

enum Level: GameLevel {
    case Easy, Normal, Hard
    
    var nbrOfCards: Int{
        switch self {
        case .Easy:
            return 6
        case .Normal:
            return 12
        case .Hard:
            return 20
        }
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

struct GameSettings{
    var level: Level = .Normal
    var username: String = "netlightconsulting"
}

class SettingsVC: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var levelSegmentedControl: UISegmentedControl!
    @IBOutlet weak var startGameButton: UIButton!
    
    var settings: GameSettings = GameSettings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if let username: String = usernameTextField.text where !username.isEmpty{
            settings.username = username
        }

        if segue?.identifier == "startGameSegue" {
            if let vc = segue?.destinationViewController as? GameVC{
                vc.gameSettings = settings
            }
            
        }
    }

    @IBAction func changedLevel(sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex{
        case 0:
            settings.level = .Easy
        case 1:
            settings.level = .Normal
        case 2:
            settings.level = .Hard
        default:
            break
        }
    }
}
