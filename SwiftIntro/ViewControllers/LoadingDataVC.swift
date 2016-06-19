//
//  LoadingDataVC.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 19/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import UIKit
import Alamofire

private let startGameSegue = "startGameSegue"
class LoadingDataVC: UIViewController, Configurable {

    //MARK: Variables
    @IBOutlet weak var loadingLabel: UILabel!

    var config: GameConfiguration!
    private var memoryCards: [CardModel]?

    private var imagesLeftToFetchCount: Int = Int.max {
        didSet {
            guard imagesLeftToFetchCount == 0 else { return }
            shouldStartGame = true
        }
    }

    private var shouldStartGame: Bool = false {
        didSet {
            guard shouldStartGame else { return }
            self.startGame()
        }
    }

    var dataSourceAndDelegate: MemoryDataSourceAndDelegate!


    //MARK: VC Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        guard let vc = segue?.destinationViewController as? GameVC else { return }
        vc.config = config
        vc.memoryCards = memoryCards
    }
}

private extension LoadingDataVC {

    private func startGame() {
        performSegueWithIdentifier(startGameSegue, sender: self)
    }

    private func setupViews() {
        setupLocalizedText()
    }

    private func setupLocalizedText() {
        loadingLabel.setLocalizedText("Loading")
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
        imagesLeftToFetchCount = cardModels.count
        prefetchImagesForCard(cardModels)
        memoryCards = memoryCardsFromModels(cardModels, cardCount: config.level.nbrOfCards)
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
            self.imagesLeftToFetchCount -= 1
        }
    }

}