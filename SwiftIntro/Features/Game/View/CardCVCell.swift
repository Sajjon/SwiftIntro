//
//  CardCVCell.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 01/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import UIKit

/// A single card cell in the memory game grid.
///
/// Displays either the card back (brown placeholder) or the card front (the fetched image),
/// and supports an animated flip transition between the two states.
final class CardCVCell: UICollectionViewCell {
    /// Displays the card's image when face-up. Hidden by default.
    let cardFrontImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    /// Plain coloured view shown when the card is face-down.
    let cardBackImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .brown
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    /// Tracks the current face-up/down state and keeps both image views in sync.
    private var isFlipped: Bool = false {
        didSet {
            cardFrontImageView.isVisible = isFlipped
            cardBackImageView.isHidden = isFlipped
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }
}

// MARK: Override

extension CardCVCell {
    /// Resets the cell to face-down with no image before it is recycled by the reuse pool.
    override func prepareForReuse() {
        super.prepareForReuse()
        cardFrontImageView.image = nil
        isFlipped = false
    }
}

// MARK: Internal

extension CardCVCell {
    /// Configures the cell to match the given card model state.
    ///
    /// Called from `willDisplay` via the `configureCell` closure. Uses Kingfisher
    /// to load (or retrieve from cache) the card's image asynchronously.
    func configure(with cardModel: CardModel) {
        cardFrontImageView.kf.setImage(with: cardModel.imageUrl)
        isFlipped = cardModel.isFlipped
    }

    /// Plays a 3D flip animation to show or hide the card face.
    ///
    /// - Parameter faceUp: `true` flips left-to-right (reveal), `false` flips right-to-left (hide).
    ///
    /// `.showHideTransitionViews` lets UIKit manage `isHidden` during the animation so
    /// both views are never simultaneously visible mid-transition.
    func animateFlip(faceUp: Bool) {
        let flipDirection: UIView.AnimationOptions = faceUp ? .transitionFlipFromLeft : .transitionFlipFromRight

        UIView.transition(
            with: contentView,
            duration: 0.6,
            options: [flipDirection, .showHideTransitionViews]
        ) {
            self.cardFrontImageView.isHidden = !faceUp
            self.cardBackImageView.isHidden = faceUp
        }
    }
}

// MARK: Private

extension CardCVCell {
    private func setupViews() {
        contentView.addSubview(cardFrontImageView)
        contentView.addSubview(cardBackImageView)
        activateImageViewConstraints()
        // `didSet` does not fire during `init`, so set the initial visibility explicitly.
        cardFrontImageView.isHidden = true
        cardBackImageView.isHidden = false
    }

    private func activateImageViewConstraints() {
        NSLayoutConstraint.activate([
            cardFrontImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardFrontImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardFrontImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardFrontImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            cardBackImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardBackImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardBackImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardBackImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}

// MARK: - CellProtocol

extension CardCVCell: CellProtocol {
    /// Reuse identifier derived from the class name, matching the `register` call in `GameVC`.
    static var cellIdentifier: String {
        className
    }
}
