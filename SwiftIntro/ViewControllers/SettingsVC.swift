//
//  SettingsVC.swift
//  SwiftIntro
//
//  Created by Miriam Tisander on 02/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import Foundation
import UIKit


enum Level: Int {
    case Easy = 0
    case Normal = 1
    case Hard = 2
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
        //setupDefaultSettings()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if segue?.identifier == "startGameSegue" {
            if let vc = segue?.destinationViewController as? GameVC{
                //vc.setupWithSettings(settings)
            }
            
        }
    }

    @IBAction func changeLevel(sender: UISegmentedControl) {
        
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
        print(settings.level)
    }
}

//private extension SettingsVC {
//    
//    
//    
//    private func setupSettings(){
//        
//    }
//}