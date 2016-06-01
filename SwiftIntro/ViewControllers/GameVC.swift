//
//  GameVC.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 01/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import UIKit

class GameVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private var dataSourceAndDelegate: MemoryDataSourceAndDelegate! {
        didSet {
            collectionView.dataSource = dataSourceAndDelegate
            collectionView.delegate = dataSourceAndDelegate
            collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }
}

private extension GameVC {
    private func fetchData() {
        showLoader()
        APIClient.sharedInstance.getPhotos {
            (result: Result<CardModel>) in
            guard let models = result.models else { return }
            self.hideLoader()
            self.dataSourceAndDelegate = MemoryDataSourceAndDelegate(models)
        }
    }
}