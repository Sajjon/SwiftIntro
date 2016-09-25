//
//  CellProtocol.swift
//  SwiftIntro
//
//  Created by Alexander Georgii-Hemming Cyon on 20/06/16.
//  Copyright © 2016 SwiftIntro. All rights reserved.
//

import UIKit

protocol CellProtocol {
    static var cellIdentifier: String {get}
    static var nib: UINib {get}
    func configure<T: Model>(with model: T, image: UIImage?)
}
