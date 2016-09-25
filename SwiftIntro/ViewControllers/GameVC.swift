//
//  GameVC.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 01/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import UIKit

private let gameOverSeque = "gameOverSeque"
class GameVC: UIViewController, Configurable {

    //MARK: Variables
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var labelsView: UIView!
    var config: GameConfiguration!
    var cards: Cards!
    fileprivate var result: GameResult!
    var imageCache: ImageCacheProtocol!
    
    fileprivate lazy var dataSourceAndDelegate: MemoryDataSourceAndDelegate = {
        let dataSourceAndDelegate = MemoryDataSourceAndDelegate(
            self.cards,
            level: self.config.level,
            delegate: self,
            imageCache: self.imageCache
            )
        return dataSourceAndDelegate
    }()

    //MARK: Instantiation
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    //MARK: VC Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func prepare(for segue: UIStoryboardSegue?, sender: Any?) {
        guard var configurable = segue?.destination as? Configurable else { return }
        configurable.config = config
        guard let vc = segue?.destination as? GameOverVC else { return }
        vc.result = result
    }
}

//MARK: GameDelegate
extension GameVC: GameDelegate {
    
    func foundMatch(_ matches: Int) {
        setScoreLabel(matches)
    }

    func gameOver(_ result: GameResult) {
        self.result = result
        self.result.cards = cards
        collectionView.isUserInteractionEnabled = false
        delay(1) {
            self.performSegue(withIdentifier: gameOverSeque, sender: self)
        }
    }
    
    fileprivate func setScoreLabel(_ matches: Int) {
        let unformatted = localizedString("PairsFoundUnformatted") as NSString
        let formatted = NSString(format: unformatted, matches, config.level.cardCount/2)
        scoreLabel.text = formatted as String
    }
}

//MARK: Private Methods
private extension GameVC {
    func setupStyling() {
        setScoreLabel(0)
        labelsView.backgroundColor = UIColor.black
        collectionView.backgroundColor = UIColor.black
    }

    func setupViews() {
        collectionView.dataSource = dataSourceAndDelegate
        collectionView.delegate = dataSourceAndDelegate
        collectionView.register(CardCVCell.nib, forCellWithReuseIdentifier: CardCVCell.cellIdentifier)
        setupStyling()
    }
}
