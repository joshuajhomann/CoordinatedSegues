//
//  GiphyListViewModel.swift
//  RxGiphy
//
//  Created by Joshua Homann on 11/3/18.
//  Copyright © 2018 com.josh. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol GiphyListViewModelProtocol: SegueCoordinator {
    var searchText: BehaviorRelay<String> { get }
    var cellViewModels: Driver<[GiphyCellViewModel]> { get }
    var selectedGiphy: BehaviorRelay<Giphy?> { get }
    func prepare(for segue: UIStoryboardSegue)
}

struct GiphyListViewModel: GiphyListViewModelProtocol {
    let searchText = BehaviorRelay<String>(value: "")
    let cellViewModels: Driver<[GiphyCellViewModel]>
    let selectedGiphy: BehaviorRelay<Giphy?> = .init(value: nil)
    private let coordinator: CoordinatorProtocol
    init(coordinator: CoordinatorProtocol, giphyService: GiphyServiceProtocol, giphyCacheService: GifCacheServiceProtocol) {
        cellViewModels = searchText.flatMapLatest { (term: String) ->  Observable<[GiphyCellViewModel]> in
            guard term.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
                return .just([])
            }
            return giphyService
                .getSearchResults(term: term, page: 0)
                .map { $0.data.map { GiphyCellViewModel(coordinator: coordinator, gifCacheService: giphyCacheService, giphy: $0) } }
            }.asDriver(onErrorJustReturn: [])
        self.coordinator = coordinator
    }
}

extension GiphyListViewModel: SegueCoordinator {
    func prepare(for segue: UIStoryboardSegue) {
        guard let destination = segue.destination as? GiphyDetailViewController,
              let selectedGiphy = selectedGiphy.value else {
            return
        }
        coordinator.handle(.showDetail(destination, selectedGiphy))
    }
}
