//
//  CardCVCell.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 01/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import UIKit

protocol CellProtocol {
    static var cellIdentifier: String {get}
    func updateWithModel(model: Model)
}

class CardCVCell: UICollectionViewCell {

}

extension CardCVCell: CellProtocol {
    static var cellIdentifier: String {
        return "Do this"
    }

    func updateWithModel(model: Model) {
        print("implement me")
    }
}