//
//  Coordinator.swift
//  RxGiphy
//
//  Created by Joshua Homann on 10/9/18.
//  Copyright © 2018 com.josh. All rights reserved.
//

import UIKit

protocol CoordinatorProtocol {
    func handle(_ action: CoordinatorAction)
}

enum CoordinatorAction {
    case showSearch, showDetail(GiphyDetailViewController, Giphy), closeDetail
}


final class Coordinator: CoordinatorProtocol {
    let dependencies: Dependencies
    let navigationController: UINavigationController
    init(initialAction: CoordinatorAction, dependencies: Dependencies) {
        self.dependencies = dependencies
        navigationController = UINavigationController()
        navigationController.definesPresentationContext = true
        handle(initialAction)
    }

    func handle(_ action: CoordinatorAction) {
        switch action {
        case .showSearch:
            guard let viewController = UIStoryboard(name: "main", bundle: nil)
                  .instantiateViewController(withIdentifier: GiphyListViewController.name) as? GiphyListViewController else {
                return
            }
            viewController.viewModel = GiphyListViewModel(coordinator: self,
                                                          giphyService: dependencies.giphyService,
                                                          giphyCacheService: dependencies.gifCacheService)
            navigationController.pushViewController(viewController, animated: true)
        case .showDetail(let giphyDetailViewController, let giphy):
            let viewModel = GiphyDetailViewModel(coordinator: self,
                                                 gifCacheService: dependencies.gifCacheService,
                                                 giphy: giphy)
            giphyDetailViewController.viewModel = viewModel
            return
        case .closeDetail:
            navigationController.dismiss(animated: true, completion: nil)
            return
        }
    }
}

final class MockCoordinator: CoordinatorProtocol {
    var lastAction: CoordinatorAction?
    func handle(_ action: CoordinatorAction) {
        self.lastAction = action
    }
}
