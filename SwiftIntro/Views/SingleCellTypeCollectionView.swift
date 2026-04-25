//
//  SingleCellTypeCollectionView.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 2026-04-23.
//  Copyright © 2026 SwiftIntro. All rights reserved.
//

import UIKit

final class SingleCellTypeCollectionView<Cell: UICollectionViewCell & CellProtocol>: UICollectionView {
    init(
        dataSource: (any UICollectionViewDataSource)?,
        delegate: (any UICollectionViewDelegate)?
    ) {
        let layout = UICollectionViewFlowLayout()
        // Uniform spacing between rows and between columns.
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        super.init(frame: .zero, collectionViewLayout: layout)

        backgroundColor = .black
        translatesAutoresizingMaskIntoConstraints = false
        register(Cell.self, forCellWithReuseIdentifier: Self.reuseIdentifier)
        self.delegate = delegate
        self.dataSource = dataSource
    }

    @available(*, unavailable, message: "Use init(dataSource:delegate:) instead.")
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) is unavailable — use init(dataSource:delegate:) instead.")
    }
}

extension SingleCellTypeCollectionView {
    func cellForItemAt(_ indexPath: IndexPath) -> Cell? {
        guard let cell = super.cellForItem(at: indexPath) as? Cell else {
            return nil
        }
        return cell
    }

    func dequeueReusableCell(at indexPath: IndexPath) -> Cell {
        let dequeued = dequeueReusableCell(withReuseIdentifier: Self.reuseIdentifier, for: indexPath)
        guard let cell = dequeued as? Cell else {
            fatalError(
                "Programmer error — wrong cell type for reuseIdentifier '\(Self.reuseIdentifier)'. "
                    + "Expected: \(Cell.self), actual: \(type(of: dequeued))."
            )
        }
        return cell
    }
}

extension SingleCellTypeCollectionView {
    static var reuseIdentifier: String {
        Cell.cellIdentifier
    }

    /// Creates and registers `Cell.self` as single cell kind.
    ///
    /// Inside this generic extension, the unqualified `SingleCellTypeCollectionView`
    /// is implicitly specialised as `SingleCellTypeCollectionView<Cell>`.
    static func make() -> SingleCellTypeCollectionView {
        SingleCellTypeCollectionView(
            dataSource: nil,
            delegate: nil
        )
    }
}
