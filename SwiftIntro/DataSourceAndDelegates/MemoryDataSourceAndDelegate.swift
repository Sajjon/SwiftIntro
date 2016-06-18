//
//  MemoryDataSourceAndDelegate.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 01/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import UIKit

struct GameResult {
    let level: Level
    let clickCount: Int

    init(cardCount: Int, clickCount: Int) {
        level = Level(rawValue: cardCount)!
        self.clickCount = clickCount
    }
}

protocol GameDelegate: class {
    func foundMatch(matches: Int)
    func gameOver(result: GameResult)
}

class MemoryDataSourceAndDelegate: NSObject {

    private var models: [CardModel]?

    var gameLevel: Level?
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
            let result = GameResult(cardCount: cardCount, clickCount: clickCount)
            delegate?.gameOver(result)
        }
    }

    init(_ models: [CardModel], delegate: GameDelegate) {
        self.models = models
        self.gameLevel = level
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

//MARK: Data Source

extension MemoryDataSourceAndDelegate: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameLevel?.columnCount ?? 0
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return gameLevel?.rowCount ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CardCVCell.cellIdentifier, forIndexPath: indexPath)
        return cell
    }
}

//MARK: Delegate

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

//MARK: Flow Layout

extension MemoryDataSourceAndDelegate: UICollectionViewDelegateFlowLayout {
    
//    func collectionView(collectionView: UICollectionView,
//                          layout collectionViewLayout: UICollectionViewLayout,
//                                 minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
//        return 50
//    }
    
    func collectionView(collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                                 insetForSectionAtIndex section: Int) -> UIEdgeInsets{
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return UIEdgeInsetsMake(0,0,0,0) }
        return UIEdgeInsetsMake(0, 0, flowLayout.minimumLineSpacing, 0); // top, left, bottom, right
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return CGSizeZero }
        
        let rownCount = gameLevel?.rowCount ?? 0
        let totalSpaceHeight = flowLayout.sectionInset.top
            + flowLayout.sectionInset.bottom
            + (flowLayout.minimumLineSpacing * CGFloat(rownCount - 1))
        let miniumumHeight = Int((collectionView.bounds.height - totalSpaceHeight) / CGFloat(rownCount))
    print(flowLayout.minimumLineSpacing)
        
        let columnCount = gameLevel?.columnCount ?? 0
        let totalSpaceWidth = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(columnCount - 1))
        let miniumumWidth = Int((collectionView.bounds.width - totalSpaceWidth) / CGFloat(columnCount))
        
            return CGSize(width: miniumumWidth, height: miniumumHeight)
    }
    
    
}