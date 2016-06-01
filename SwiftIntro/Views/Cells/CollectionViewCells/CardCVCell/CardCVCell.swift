//
//  CardCVCell.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 01/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import UIKit

protocol CellProtocol {
    var cellIdentifier: String {get}
}

class CardCVCell: UICollectionViewCell {

}

extension CardCVCell: CellProtocol {
    var cellIdentifier: String {
        return "Do this"
    }
}