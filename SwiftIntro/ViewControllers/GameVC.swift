//
//  GameVC.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 01/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import UIKit
import Alamofire

private let gameOverSeque = "gameOverSeque"
class GameVC: UIViewController, Configurable {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var labelsView: UIView!
    var config: GameConfiguration!
    private var gameResult: GameResult!
    
    private var dataSourceAndDelegate: MemoryDataSourceAndDelegate! {
        didSet {
            collectionView.dataSource = dataSourceAndDelegate
            collectionView.delegate = dataSourceAndDelegate
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        guard segue?.identifier == gameOverSeque else { return }
        guard let vc = segue?.destinationViewController as? GameOverVC else { return }
        vc.config = config
        vc.result = gameResult
    }

    @IBAction func quitAction(sender: AnyObject) {
       self.dismissViewControllerAnimated(true) {
        
        }
    }
    
}

//MARK: GameDelegate
extension GameVC: GameDelegate {
    
    func foundMatch(matches: Int) {
        setScoreLabel(matches)
    }

    func gameOver(result: GameResult) {
        self.gameResult = result
        performSegueWithIdentifier(gameOverSeque, sender: self)
    }
    
    private func setScoreLabel(matches: Int) {
        let unformatted = localizedString("PairsFoundUnformatted")
        let formatted = NSString(format: unformatted, matches, config.level.nbrOfCards/2)
        scoreLabel.text = formatted as String
    }
}


//MARK: Setup and Styling
private extension GameVC {
    private func setupStyling() {
        setScoreLabel(0)
        labelsView.backgroundColor = .blackColor()
        collectionView.backgroundColor = .blackColor()
    }

    private func setupViews() {
        collectionView.registerNib(CardCVCell.nib, forCellWithReuseIdentifier: CardCVCell.cellIdentifier)
        setupStyling()
    }

    private func fetchData() {
        showLoader()
        APIClient.sharedInstance.getPhotos(config.username) {
            (result: Result<MediaModel>) in
            self.hideLoader()
            self.setupWithModel(result.model)
        }
    }

    private func setupWithModel(model: MediaModel?) {
        guard let model = model else { return }
        let cardModels = model.cardModels
        let memoryCards = memoryCardsFromModels(cardModels, cardCount: config.level.nbrOfCards)
        dataSourceAndDelegate = MemoryDataSourceAndDelegate(memoryCards, level: config.level, delegate: self)
        prefetchImagesForCard(memoryCards)
    }

    private func memoryCardsFromModels(cardModels: [CardModel], cardCount: Int) -> [CardModel] {
        let cardCount = min(cardModels.count, cardCount)
        var memoryCards = cardModels
        memoryCards.shuffle()
        memoryCards = memoryCards.choose(cardCount/2)
        var duplicated = duplicatedMemoryCards(memoryCards)
        duplicated.shuffle()
        return duplicated
    }

    private func duplicatedMemoryCards(cards: [CardModel]) -> [CardModel] {
        var duplicated: [CardModel] = []
        for memoryCard in cards {
            let duplicate = CardModel(imageUrl: memoryCard.imageUrl)
            duplicated.append(duplicate)
            duplicated.append(memoryCard)
        }
        return duplicated
    }

    private func prefetchImagesForCard(cards: [CardModel]) {
        let urls: [URLRequestConvertible] = cards.map { return URL(url: $0.imageUrl) }
        ImagePrefetcher.sharedInstance.prefetchImages(urls) {
            self.collectionView.reloadData()
        }
    }

}