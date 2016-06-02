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

    init(_ models: [CardModel]) {
        self.models = models
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

extension MemoryDataSourceAndDelegate: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return CGSizeZero }
        let margin = flowLayout.minimumInteritemSpacing
        let side: CGFloat = collectionView.frame.width/2 - margin
        let size = CGSizeMake(side, side)
        return size
    }
}