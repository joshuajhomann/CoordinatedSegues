//
//  GiphyListViewController.swift
//  GiphyBrowser
//
//  Created by Joshua Homann on 7/15/18.
//  Copyright © 2018 com.josh. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Action

class GiphyListViewController: UIViewController, ViewModelOwner, SeguesCoordinated {
    typealias ViewModel = GiphyListViewModel
    var viewModel: ViewModel?
    @IBOutlet weak var collectionView: UICollectionView!
    private static let numberOfItemsAcross: CGFloat = 2
    private var searchResults: [Giphy] = []
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search for new giphies..."
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        return searchController
    }()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Giphy Search"
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        guard let viewModel = viewModel else {
            return
        }
        viewModel
            .cellViewModels
            .drive(collectionView
                .rx
                .items(cellIdentifier: GiphyCollectionViewCell.name, cellType: GiphyCollectionViewCell.self)) { indexPath, viewModel, cell in
                    cell.configure(with: viewModel)
            }.disposed(by: disposeBag)

        collectionView
            .rx
            .modelSelected(GiphyCellViewModel.self)
            .observeOn(MainScheduler())
            .subscribe(onNext: { [weak self] (cellViewModel: GiphyCellViewModel) in
                viewModel.selectedGiphy.accept(cellViewModel.giphy)
                self?.performSegue(withIdentifier: GiphyDetailViewController.name, sender: nil)
            }).disposed(by: disposeBag)

        searchController
        .searchBar
        .rx
        .text
        .orEmpty
        .debounce(0.25, scheduler: MainScheduler())
        .distinctUntilChanged()
        .bind(to: viewModel.searchText)
        .disposed(by: disposeBag)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        let remainingSpace = collectionView.bounds.width
                            - flowLayout.sectionInset.left
                            - flowLayout.sectionInset.right
                            - flowLayout.minimumInteritemSpacing * (GiphyListViewController.numberOfItemsAcross - 1)
        let dimension = remainingSpace / GiphyListViewController.numberOfItemsAcross
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        dismiss(animated: false, completion: nil)
    }
}

