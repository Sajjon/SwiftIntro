//
//  MemoryDataSourceAndDelegate.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 01/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import UIKit

protocol GameDelegate: class {
    func foundMatch(matches: Int)
    func gameOver(result: GameResult)
}

//MARK: Class init and private variables
class MemoryDataSourceAndDelegate: NSObject {

    private let cards: Cards
    private let gameLevel: Level
    private weak var delegate: GameDelegate?

    private var clickCount = 0

    private var cardCount: Int {
        return cards.count
    }

    private var flippedCardIndexPath: NSIndexPath?

    private var matches: Int = 0 {
        didSet {
            delegate?.foundMatch(matches)
            gameOver = matches == cardCount/2
        }
    }

    private var gameOver: Bool = false {
        didSet {
            guard gameOver else { return }
            let result = GameResult(level: gameLevel, clickCount: clickCount)
            delegate?.gameOver(result)
        }
    }

    init(_ cards: Cards, level: Level, delegate: GameDelegate) {
        self.cards = cards
        self.gameLevel = level
        self.delegate = delegate
    }
}

//MARK: Game play Methods
private extension MemoryDataSourceAndDelegate {
    
    private func cardForIndexPath(indexPath: NSIndexPath) -> Card? {
        guard indexPath.row < cards.count else { return nil }
        let index = indexFromIndexPath(indexPath)
        let model = cards[index]
        return model
    }
    
    private func indexFromIndexPath(indexPath: NSIndexPath) -> Int {
        let numberOfItemsInSection = gameLevel.columnCount
        let index = indexPath.row + (numberOfItemsInSection * indexPath.section)
        return index
    }
    
    private func didSelectCardAtIndexPath(indexPath: NSIndexPath, inCollectionView collectionView: UICollectionView) {
        clickCount += 1
        flipCardAtIndexPath(indexPath, inCollectionView: collectionView)
        if let flippedCardIndexPath = flippedCardIndexPath { /* Found previously flipped card */
            /* We should should always toss away info about "previously flipped card", 
             disregarding if card just flipped matches previously flipped card or not, since
             if the match, we want to search for a new pair, if they don't match, se should 
             search for a new pair.
             */
            self.flippedCardIndexPath = nil
            guard flippedCardIndexPath != indexPath else { return }
            checkIfCardAtIndexPath(indexPath,
                                   inCollectionView: collectionView,
                                   matchesAlreadyFlippedCard: flippedCardIndexPath)
        } else {
            flippedCardIndexPath = indexPath
        }
    }

    private func flipCardAtIndexPath(indexPath: NSIndexPath, inCollectionView collectionView: UICollectionView) {
        guard let card = cardForIndexPath(indexPath) else { return }
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? CardCVCell else { return }
        cell.flipCard(card)
    }

    private func checkIfCardAtIndexPath(indexPath: NSIndexPath,
                                        inCollectionView collectionView: UICollectionView,
                                                         matchesAlreadyFlippedCard flippedIndexPath: NSIndexPath) {
        guard let card = cardForIndexPath(indexPath) else { return }
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? CardCVCell else { return }
        guard let flippedCard = cardForIndexPath(flippedIndexPath) else { return }
        guard let flippedCell = collectionView.cellForItemAtIndexPath(flippedIndexPath) as? CardCVCell else { return }
        checkIfCard(card, withCell: cell, matchesFlippedCard: flippedCard, withCell: flippedCell)
    }

    //swiftlint:disable opening_brace
    private func checkIfCard(card: Card,
                                 withCell cell: CardCVCell,
                                          matchesFlippedCard flippedCard: Card,
                                                                    withCell flippedCell: CardCVCell)
    {
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

    private func cardAtIndexPathAlreadyMatched(indexPath: NSIndexPath) -> Bool {
        guard let card = cardForIndexPath(indexPath) else { return false }
        let alreadyMatched = card.matched
        return alreadyMatched
    }

    private func calculateCardSize(flowLayout: UICollectionViewFlowLayout, collectionView: UICollectionView) -> CGSize {

        let miniumumHeight = calculateMiniumumHeight(flowLayout, collectionView: collectionView)
        let miniumumWidth = calculateMiniumumWidth(flowLayout, collectionView: collectionView)
        let lengthOfSide = min(miniumumWidth, miniumumHeight)
        let size = CGSize(width: lengthOfSide, height: lengthOfSide)
        return size
    }

    private func calculateMiniumumHeight(flowLayout: UICollectionViewFlowLayout, collectionView: UICollectionView) -> CGFloat {
        let rowCount = CGFloat(gameLevel.rowCount)
        let sectionSpace = flowLayout.sectionInset.top + flowLayout.sectionInset.bottom
        let totalSpaceHeight = sectionSpace + (flowLayout.minimumLineSpacing * (rowCount - 1))
        let height = trunc((collectionView.bounds.height - totalSpaceHeight) / rowCount)
        return height
    }

    private func calculateMiniumumWidth(flowLayout: UICollectionViewFlowLayout, collectionView: UICollectionView) -> CGFloat {
        let columnCount = CGFloat(gameLevel.columnCount)
        let sectionSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right
        let totalSpaceWidth = sectionSpace + (flowLayout.minimumInteritemSpacing * (columnCount - 1))
        let width = trunc((collectionView.bounds.width - totalSpaceWidth) / columnCount)
        return width
    }
}

//MARK: UICollectionViewDataSource Methods
extension MemoryDataSourceAndDelegate: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameLevel.columnCount
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return gameLevel.rowCount
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CardCVCell.cellIdentifier, forIndexPath: indexPath)
        return cell
    }
}

//MARK: UICollectionViewDelegate Methods
extension MemoryDataSourceAndDelegate: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard cardAtIndexPathAlreadyMatched(indexPath) == false else { return }
        didSelectCardAtIndexPath(indexPath, inCollectionView: collectionView)
    }

    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? CardCVCell else { return }
        guard let model = cardForIndexPath(indexPath) else { return }
        cell.updateWithModel(model)
    }
}

//MARK: UICollectionViewDelegateFlowLayout Methods
extension MemoryDataSourceAndDelegate: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                                 insetForSectionAtIndex section: Int) -> UIEdgeInsets{
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return UIEdgeInsetsZero }

        let insets = UIEdgeInsets(top: 0, left: 0, bottom: flowLayout.minimumLineSpacing, right: 0)
        return insets
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize.zero }
        
        return calculateCardSize(flowLayout, collectionView: collectionView)
    }
}