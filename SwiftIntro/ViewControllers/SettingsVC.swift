//
//  SettingsVC.swift
//  SwiftIntro
//
//  Created by Miriam Tisander on 02/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Foundation
import UIKit

class SettingsVC: UIViewController, Configurable {

    //MARK: Variables
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var segmentTitleLabel: UILabel!
    @IBOutlet weak var levelSegmentedControl: UISegmentedControl!
    @IBOutlet weak var startGameButton: UIButton!
    
    var config: GameConfiguration!

    //MARK: Initializers
    required init?(coder aDecoder: NSCoder) {
        self.config = GameConfiguration()
        super.init(coder: aDecoder)
    }

    //MARK: VC Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        populateViews()
    }

    override func prepare(for segue: UIStoryboardSegue?, sender: Any?) {
        guard let vc = segue?.destination as? LoadingDataVC else { return }
        if let searchQuery: String = usernameTextField.text, !searchQuery.isEmpty {
            config.searchQuery = searchQuery
        }

        vc.config = config
    }

}

//MARK: IBAction Methods
extension SettingsVC {

    @IBAction func changedLevel(_ sender: UISegmentedControl) {
        let level = Level(segmentedControlIndex: sender.selectedSegmentIndex)
        config.level = level
    }
}

private extension SettingsVC {

    func setupViews() {
        setupLocalizableStrings()
        //startGameButton.layer.cornerRadius = startGameButton.frame.size.height/2
    }

    func populateViews() {
        usernameTextField.text = config.searchQuery
        levelSegmentedControl.selectedSegmentIndex = config.level.segmentedControlIndex
    }

    func setupLocalizableStrings() {
        titleLabel.setLocalizedText(.title)
        usernameTextField.placeholder = tr(key: .usernamePlaceholder)
        segmentTitleLabel.setLocalizedText(.level)
        setupLocalizationForSegmentedControl()
        usernameLabel.setLocalizedText(.username)
        startGameButton.setLocalizedTitle(.startGame)
    }

    func setupLocalizationForSegmentedControl() {
        for i in 0...2 {
            let level = Level(segmentedControlIndex: i)
            let title = level.title
            levelSegmentedControl.setTitle(title, forSegmentAt: i)
        }
    }
}
