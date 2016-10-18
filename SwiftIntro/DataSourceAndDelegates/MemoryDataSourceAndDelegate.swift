//
//  MemoryDataSourceAndDelegate.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 01/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import UIKit

protocol GameDelegate: class {
    func foundMatch(_ matches: Int)
    func gameOver(_ result: GameResult)
}

//MARK: Class init and private variables
class MemoryDataSourceAndDelegate: NSObject {

    fileprivate let cards: Cards
    fileprivate let gameLevel: Level
    fileprivate weak var delegate: GameDelegate?
    fileprivate let imageCache: ImageCacheProtocol

    fileprivate var clickCount = 0

    fileprivate var cardCount: Int {
        return cards.count
    }

    fileprivate var flippedCardIndexPath: IndexPath?

    fileprivate var matches: Int = 0 {
        didSet {
            delegate?.foundMatch(matches)
            gameOver = matches == cardCount/2
        }
    }

    fileprivate var gameOver: Bool = false {
        didSet {
            guard gameOver else { return }
            let result = GameResult(level: gameLevel, clickCount: clickCount)
            delegate?.gameOver(result)
        }
    }

    init(_ cards: Cards,
           level: Level,
           delegate: GameDelegate,
           imageCache: ImageCacheProtocol
        ) {
        self.cards = cards
        self.gameLevel = level
        self.delegate = delegate
        self.imageCache = imageCache
    }
}

//MARK: Game play Methods
private extension MemoryDataSourceAndDelegate {
    
    func cardAt(_ indexPath: IndexPath) -> Card? {
        guard indexPath.row < cards.count else { return nil }
        let index = indexWith(indexPath)
        let model = cards[index]
        return model
    }
    
    func indexWith(_ indexPath: IndexPath) -> Int {
        let numberOfItemsInSection = gameLevel.columnCount
        let index = indexPath.row + (numberOfItemsInSection * indexPath.section)
        return index
    }
    
    func didSelectCard(at indexPath: IndexPath, in collectionView: UICollectionView) {
        clickCount += 1
        flipCard(at: indexPath, in: collectionView)
        if let flippedCardIndexPath = flippedCardIndexPath { /* Found previously flipped card */
            /* We should should always toss away info about "previously flipped card", 
             disregarding if card just flipped matches previously flipped card or not, since
             if the match, we want to search for a new pair, if they don't match, se should 
             search for a new pair.
             */
            self.flippedCardIndexPath = nil
            guard flippedCardIndexPath != indexPath else { return }
            checkIfCard(at: indexPath, in: collectionView, matches: flippedCardIndexPath)
        } else {
            flippedCardIndexPath = indexPath
        }
    }

    func flipCard(at indexPath: IndexPath, in collectionView: UICollectionView) {
        guard
            let card = cardAt(indexPath),
            let cell = collectionView.cellForItem(at: indexPath) as? CardCVCell
        else { return }
        cell.flipCard(card)
    }

    func checkIfCard(at indexPath: IndexPath, in collectionView: UICollectionView, matches flippedCardIndexPath: IndexPath) {
        guard
            let card = cardAt(indexPath),
            let cell = collectionView.cellForItem(at: indexPath) as? CardCVCell,
            let flippedCard = cardAt(flippedCardIndexPath),
            let flippedCell = collectionView.cellForItem(at: flippedCardIndexPath) as? CardCVCell
        else { return }
        checkIfCard(card, withCell: cell, matchesFlippedCard: flippedCard, withCell: flippedCell)
    }

    func checkIfCard(_ card: Card, withCell cell: CardCVCell, matchesFlippedCard flippedCard: Card, withCell flippedCell: CardCVCell) {
        if card == flippedCard {
            matches += 1
            card.matched = true
            flippedCard.matched = true
        } else {
            /* No match, flip back cards after delay */
            delay(1) {
                cell.flipCard(card)
                flippedCell.flipCard(flippedCard)
            }
        }
    }

    func cardAtIndexPathAlreadyMatched(_ indexPath: IndexPath) -> Bool {
        guard let card = cardAt(indexPath) else { return false }
        let alreadyMatched = card.matched
        return alreadyMatched
    }

    func calculateCardSize(_ flowLayout: UICollectionViewFlowLayout, collectionView: UICollectionView) -> CGSize {

        let miniumumHeight = calculateMiniumumHeight(flowLayout, collectionView: collectionView)
        let miniumumWidth = calculateMiniumumWidth(flowLayout, collectionView: collectionView)
        let lengthOfSide = min(miniumumWidth, miniumumHeight)
        let size = CGSize(width: lengthOfSide, height: lengthOfSide)
        return size
    }

    func calculateMiniumumHeight(_ flowLayout: UICollectionViewFlowLayout, collectionView: UICollectionView) -> CGFloat {
        let rowCount = CGFloat(gameLevel.rowCount)
        let sectionSpace = flowLayout.sectionInset.top + flowLayout.sectionInset.bottom
        let totalSpaceHeight = sectionSpace + (flowLayout.minimumLineSpacing * (rowCount - 1))
        let height = trunc((collectionView.bounds.height - totalSpaceHeight) / rowCount)
        return height
    }

    func calculateMiniumumWidth(_ flowLayout: UICollectionViewFlowLayout, collectionView: UICollectionView) -> CGFloat {
        let columnCount = CGFloat(gameLevel.columnCount)
        let sectionSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right
        let totalSpaceWidth = sectionSpace + (flowLayout.minimumInteritemSpacing * (columnCount - 1))
        let width = trunc((collectionView.bounds.width - totalSpaceWidth) / columnCount)
        return width
    }
}

//MARK: UICollectionViewDataSource Methods
extension MemoryDataSourceAndDelegate: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameLevel.columnCount
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return gameLevel.rowCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCVCell.cellIdentifier, for: indexPath)
        return cell
    }
}

//MARK: UICollectionViewDelegate Methods
extension MemoryDataSourceAndDelegate: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard cardAtIndexPathAlreadyMatched(indexPath) == false else { return }
        didSelectCard(at: indexPath, in: collectionView)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? CardCVCell else { return }
        guard let model = cardAt(indexPath) else { return }
        let cachedImage = imageCache.imageFromCache(model.imageUrl)
        cell.configure(with: model, image: cachedImage)
    }
}

//MARK: UICollectionViewDelegateFlowLayout Methods
extension MemoryDataSourceAndDelegate: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                                 insetForSectionAt section: Int) -> UIEdgeInsets{
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return UIEdgeInsets.zero }

        let insets = UIEdgeInsets(top: 0, left: 0, bottom: flowLayout.minimumLineSpacing, right: 0)
        return insets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize.zero }
        
        return calculateCardSize(flowLayout, collectionView: collectionView)
    }
}
