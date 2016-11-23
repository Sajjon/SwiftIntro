//
//  CardCVCell.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 01/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import UIKit
import Kingfisher

class CardCVCell: UICollectionViewCell {
    @IBOutlet weak var cardFrontImageView: UIImageView!
    @IBOutlet weak var cardBackImageView: UIImageView!

    fileprivate var isFlipped: Bool = false {
        didSet {
            cardFrontImageView.isVisible = isFlipped
            cardBackImageView.isHidden = isFlipped
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        cardBackImageView.backgroundColor = UIColor.brown
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cardFrontImageView.image = nil
        isFlipped = false
    }

    func flipCard(_ cardModel: Card) {
        let isFlipped = cardModel.isFlipped
        let sourceView = isFlipped ? cardFrontImageView : cardBackImageView
        let targetView = isFlipped ? cardBackImageView : cardFrontImageView
        let flipDirection: UIViewAnimationOptions = isFlipped ? .transitionFlipFromRight : .transitionFlipFromLeft
        let options: UIViewAnimationOptions = [flipDirection, .showHideTransitionViews]
        UIView.transition(from: sourceView!, to: targetView!, duration: 0.6, options: options) {
            finished in
            cardModel.isFlipped = !isFlipped
        }
    }
}

//MARK: CellProtocol Methods
extension CardCVCell: CellProtocol {

    static var nib: UINib {
        return UINib(nibName: className, bundle: nil)
    }

    static var cellIdentifier: String {
        return className
    }

    func configure<T: Model>(with model: T, image: UIImage?) {
        guard let card = model as? Card else { return }
        configure(with: card, image: image)
    }
}

private extension CardCVCell {
    func configure(with card: Card, image: UIImage?) {
        cardFrontImageView.image = image
        isFlipped = card.isFlipped
    }
}
