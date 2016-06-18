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
    func gameOver(clickCount: Int)
}

class MemoryDataSourceAndDelegate: NSObject {

    private var models: [CardModel]?
    private weak var delegate: GameDelegate?

    private var clickCount = 0

    private var cardCount: Int {
        return models?.count ?? 0
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
            delegate?.gameOver(clickCount)
        }
    }

    init(_ models: [CardModel], delegate: GameDelegate) {
        self.models = models
        self.delegate = delegate
    }
}

private extension MemoryDataSourceAndDelegate {
    private func modelForIndexPath(indexPath: NSIndexPath) -> CardModel? {
        guard let models = models else { return nil }
        guard indexPath.row < models.count else { return nil }
        let model = models[indexPath.row]
        return model
    }

    private func didSelectCardAtIndexPath(indexPath: NSIndexPath, inCollectionView collectionView: UICollectionView) {
        guard let card = modelForIndexPath(indexPath) else { return }
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? CardCVCell else { return }

        clickCount += 1
        cell.flipCard(card)

        if let flippedCardIndexPath = flippedCardIndexPath {
            self.flippedCardIndexPath = nil
            guard let flippedCard = modelForIndexPath(flippedCardIndexPath) else { return }
            guard let flippedCell = collectionView.cellForItemAtIndexPath(flippedCardIndexPath) as? CardCVCell else { return }

            if card == flippedCard {
                matches += 1
            } else {
                /* No match, flip back cards after delay */
                delay(1) {
                    cell.flipCard(card)
                    flippedCell.flipCard(flippedCard)
                }
            }
        } else {
            flippedCardIndexPath = indexPath
        }
    }
}



extension MemoryDataSourceAndDelegate: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfItems = models?.count ?? 0
        return numberOfItems
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CardCVCell.cellIdentifier, forIndexPath: indexPath)
        return cell
    }
}

extension MemoryDataSourceAndDelegate: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        didSelectCardAtIndexPath(indexPath, inCollectionView: collectionView)
    }

    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? CardCVCell else { return }
        guard let model = modelForIndexPath(indexPath) else { return }
        cell.updateWithModel(model)
    }
}

extension MemoryDataSourceAndDelegate: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return CGSizeZero }
        let margin = flowLayout.minimumInteritemSpacing
        let side: CGFloat = collectionView.frame.width/2 - margin
        let size = CGSizeMake(side, side)
        return size
    }
}