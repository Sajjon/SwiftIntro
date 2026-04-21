//
//  LoadingVC.swift
//  SwiftIntro
//
//  Created by Alexander Cyon on 19/06/16.
//  Copyright © 2016-2026 SwiftIntro. All rights reserved.
//

import Diffuser
import UIKit

// MARK: - LoadingNavigatorProtocol

/// Handles navigation triggered by `LoadingVC` once data loading is complete.
protocol LoadingNavigatorProtocol: AnyObject {
    func navigateToGame(_ game: PreparedGame)
}

// MARK: - LoadingVC

/// Installs `LoadingView`, wires the retry tap, and owns `LoadingViewModel`.
///
/// The diffuser is created here and injected into the view model at init time,
/// so the view model never holds an optional diffuser.
final class LoadingVC: UIViewController {
    /// Content view
    private let loadingView: LoadingView

    /// ViewModel with logic
    private let viewModel: LoadingViewModel

    /// Navigator which we use to navigate to next screen
    weak var navigator: LoadingNavigatorProtocol?

    init(config: GameConfiguration) {
        let view = LoadingView()
        loadingView = view
        viewModel = LoadingViewModel(
            config: config
        ) { [weak view] phase in
            view?.render(phase)
        }
        view.onRetry = { [weak viewModel] in viewModel?.retry() }
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
        viewModel.onNavigateToGame = { [weak self] game in
            self?.navigator?.navigateToGame(game)
        }
        viewModel.start()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        logNet.debug("LoadingVC disappeared — stopping view model")
        viewModel.stop()
    }
}
