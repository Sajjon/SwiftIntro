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
    private var cards: Cards?

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
        vc.cards = cards
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
        APIClient.sharedInstance.getPhotos(config.username) {
            (result: Result<Cards>) in
            self.setupWithModel(result.model)
        }
    }

    private func setupWithModel(model: Cards?) {
        guard let model = model else { return }
        let singles = model.singles
        prefetchImagesForCards(singles)
        self.cards = Cards(singles, config: config)
    }

    private func prefetchImagesForCards(cards: [Card]) {
        imagesLeftToFetchCount = cards.count
        let urls: [URLRequestConvertible] = cards.map { return URL(url: $0.imageUrl) }
        ImagePrefetcher.sharedInstance.prefetchImages(urls) {
            self.imagesLeftToFetchCount -= 1
        }
    }
}