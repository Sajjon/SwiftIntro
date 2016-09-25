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

    fileprivate var flipped: Bool = false {
        didSet {
            cardFrontImageView.isVisible = flipped
            cardBackImageView.isHidden = flipped
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        cardBackImageView.backgroundColor = UIColor.brown
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cardFrontImageView.image = nil
        flipped = false
    }

    func flipCard(_ cardModel: Card) {
        let flipped = cardModel.flipped
        let fromView = flipped ? cardFrontImageView : cardBackImageView
        let toView = flipped ? cardBackImageView : cardFrontImageView
        let flipDirection: UIViewAnimationOptions = flipped ? .transitionFlipFromRight : .transitionFlipFromLeft
        let options: UIViewAnimationOptions = [flipDirection, .showHideTransitionViews]
        UIView.transition(from: fromView!, to: toView!, duration: 0.6, options: options) {
            finished in
            cardModel.flipped = !flipped
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
        flipped = card.flipped
    }
}
