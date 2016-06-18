//
//  GameVC.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 01/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import UIKit
import Alamofire

class GameVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var labelsView: UIView!
    var gameSettings: GameSettings = GameSettings()
    
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
}

extension GameVC: GameDelegate {
    func foundMatch(matches: Int) {
        scoreLabel.text = "\(matches)"
    }

    func gameOver(result: GameResult) {
        print("Game over: \(result.clickCount)")
    }
}

private extension GameVC {
    private func setupStyling() {
        labelsView.backgroundColor = .blackColor()
        collectionView.backgroundColor = .blackColor()
    }

    private func setupViews() {
        collectionView.registerNib(CardCVCell.nib, forCellWithReuseIdentifier: CardCVCell.cellIdentifier)
        setupStyling()
    }

    private func fetchData() {
        showLoader()
        APIClient.sharedInstance.getPhotos(gameSettings.username) {
            (result: Result<MediaModel>) in
            self.hideLoader()
            self.setupWithModel(result.model)
        }
    }

    private func setupWithModel(model: MediaModel?) {
        guard let model = model else { return }
        let cardModels = model.cardModels
        let memoryCards = memoryCardsFromModels(cardModels, cardCount: gameSettings.level.nbrOfCards)
        dataSourceAndDelegate = MemoryDataSourceAndDelegate(memoryCards, level: gameSettings.level, delegate: self)
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

extension Array {
    var shuffled: Array {
        var elements = self
        for index in indices.dropLast() {
            guard
                case let swapIndex = Int(arc4random_uniform(UInt32(count - index))) + index
                where swapIndex != index else { continue }
            swap(&elements[index], &elements[swapIndex])
        }
        return elements
    }
    mutating func shuffle() {
        self = shuffled
    }

    var chooseOne: Element {
        return self[Int(arc4random_uniform(UInt32(count)))]
    }
    func choose(count: Int) -> [Element] {
        return Array(shuffled.prefix(count))
    }
}
