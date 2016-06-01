//
//  CardCVCell.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 01/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import UIKit
import AlamofireImage

protocol CellProtocol {
    static var cellIdentifier: String {get}
    static var nib: UINib {get}
    static var size: CGSize {get}
    func updateWithModel(model: Model)
}

class CardCVCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}

extension CardCVCell: CellProtocol {

    static var nib: UINib {
        return UINib(nibName: className, bundle: nil)
    }

    static var cellIdentifier: String {
        return className
    }

    static var size: CGSize {
        return CGSizeMake(200, 200)
    }

    func updateWithModel(model: Model) {
        guard let card = model as? CardModel else { return }
        imageView.af_setImageWithURL(card.imageUrl)
    }
}