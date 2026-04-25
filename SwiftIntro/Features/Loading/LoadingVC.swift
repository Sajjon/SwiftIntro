//
//  LoadingVC.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 19/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import UIKit

// MARK: - LoadingNavigatorProtocol

/// Handles navigation triggered by `LoadingVC` once data loading is complete.
protocol LoadingNavigatorProtocol: AnyObject {
    func navigateToGame(_ game: PreparedGame)
}

// MARK: - LoadingVC

/// Installs `LoadingView`, wires the retry tap, and owns `LoadingViewModel`.
///
/// The VC is a thin wiring layer: it forwards retry taps to the view model and
/// renders phase updates back onto the view. All state lives in the view model.
final class LoadingVC: UIViewController {
    /// Content view
    private let loadingView = LoadingView()

    /// ViewModel with logic
    private let viewModel: LoadingViewModel

    /// Navigator which we use to navigate to next screen
    weak var navigator: LoadingNavigatorProtocol?

    init(config: GameConfiguration) {
        viewModel = LoadingViewModel(config: config)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }
}

// MARK: Override(s)

extension LoadingVC {
    override func loadView() {
        view = loadingView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        logNet.debug("LoadingVC loaded — starting data fetch")
        loadingView.onRetry = { [weak viewModel] in viewModel?.retry() }
        viewModel.start(
            onPhaseChange: { [weak self] phase in
                self?.loadingView.render(phase)
            },
            onNavigateToGame: { [weak self] game in
                self?.navigator?.navigateToGame(game)
            }
        )
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        logNet.debug("LoadingVC disappeared — stopping view model")
        viewModel.stop()
    }
}
