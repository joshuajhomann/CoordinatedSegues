//
//  GiphyDetailViewController.swift
//  GiphyBrowser
//
//  Created by Joshua Homann on 7/15/18.
//  Copyright © 2018 com.josh. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Action
import RxGesture

class GiphyDetailViewController: UIViewController, ViewModelOwner, SeguesCoordinated {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var copiedView: UIView!
    @IBOutlet weak var copyButton: UIButton!

    typealias ViewModel = GiphyDetailViewModel
    
    var viewModel: ViewModel?
    private let disposeBag =  DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let viewModel = viewModel else {
            return
        }
        view
            .rx
            .tapGesture()
            .when(.recognized)
            .subscribeOn(MainScheduler())
            .subscribe(onNext: { [viewModel] _ in
                viewModel.closeAction.execute(())
            }).disposed(by: disposeBag)

        viewModel.titleDriver.drive(navigationItem.rx.title ).disposed(by: disposeBag)
        viewModel.titleDriver.drive(titleLabel.rx.text).disposed(by: disposeBag)
        viewModel.gifDriver.drive(imageView.rx.image).disposed(by: disposeBag)
        viewModel.ratingDriver.drive(ratingLabel.rx.text).disposed(by: disposeBag)
        viewModel.sizeDriver.drive(sizeLabel.rx.text).disposed(by: disposeBag)
        copyButton.rx.action = viewModel.copyAction
        viewModel.copyAction.elements.asDriver(onErrorJustReturn: ()).drive(onNext:{ [copiedView] () in
            guard let copiedView = copiedView else {
                return
            }
            copiedView.isHidden = false
            UIView.animate(withDuration: 1, animations: {
                self.copiedView.alpha = 0
            }, completion: {_ in
                self.copiedView.isHidden = true
                self.copiedView.alpha = 1
            })
        }).disposed(by: disposeBag)
    }
}
