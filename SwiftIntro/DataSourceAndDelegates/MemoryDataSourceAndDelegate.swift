//
//  MemoryDataSourceAndDelegate.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 01/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import UIKit

class MemoryDataSourceAndDelegate: NSObject {
    var models: [CardModel]?
    var gameLevel: Level?

    init(_ models: [CardModel], level: Level) {
        self.models = models
        self.gameLevel = level
    }
}

private extension MemoryDataSourceAndDelegate {
    private func modelForIndexPath(indexPath: NSIndexPath) -> CardModel? {
        guard let models = models else { return nil }
        guard indexPath.row < models.count else { return nil }
        let model = models[indexPath.row]
        return model
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
        guard let model = modelForIndexPath(indexPath) else { return }
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? CardCVCell else { return }
        cell.flipCard(model)
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