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
    fileprivate var cards: Cards?

    var apiClient: APIClientProtocol!
    var imageCache: ImageCacheProtocol!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    //MARK: VC Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchData()
    }

    override func prepare(for segue: UIStoryboardSegue?, sender: Any?) {
        guard let vc = segue?.destination as? GameVC else { return }
        vc.config = config
        vc.cards = cards
    }
}

private extension LoadingDataVC {

    func startGame() {
        performSegue(withIdentifier: startGameSegue, sender: self)
    }

    func setupViews() {
        setupLocalizedText()
    }

    func setupLocalizedText() {
        loadingLabel.setLocalizedText("Loading")
    }

    func fetchData() {
        apiClient.getPhotos(config.username) {
            result in
            switch result {
            case .failure(let error):
                print("Failed to get photos, error: \(error.description)")
            case .success(let model):
                self.setupWithModel(model.first)
            }
        }
    }

    func setupWithModel(_ model: Cards?) {
        guard let model = model else { return }
        let singles = model.singles
        prefetchImagesForCards(singles)
        self.cards = Cards(singles, config: config)
    }

    func prefetchImagesForCards(_ cards: [Card]) {
        let urls: [URL] = cards.map { return $0.imageUrl }
        imageCache.prefetchImages(urls) {
            self.startGame()
        }
    }
}
