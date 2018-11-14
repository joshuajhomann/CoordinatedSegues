//
//  UIStoryBoard+Coordinator.swift
//  RxGiphy
//
//  Created by Joshua Homann on 11/10/18.
//  Copyright © 2018 com.josh. All rights reserved.
//

import UIKit

protocol SeguesCoordinated {
    var segueCoordinator: SegueCoordinator? { get }
}

protocol SegueCoordinator {
    func prepare(for segue: UIStoryboardSegue)
}

protocol ViewModelOwner {
    associatedtype ViewModel
    var viewModel: ViewModel? { get }
}

extension ViewModelOwner where Self: UIViewController, ViewModel: SegueCoordinator {
    var segueCoordinator: SegueCoordinator? {
        return viewModel
    }
}

extension UIStoryboardSegue {
    @objc private func swizzledPerform() {
        (source as? SeguesCoordinated)?.segueCoordinator?.prepare(for: self)
        swizzledPerform()
    }

    private static let swizzleImplementation: Void = {
        guard let perform = class_getInstanceMethod(UIStoryboardSegue.self, #selector(UIStoryboardSegue.perform as (UIStoryboardSegue) -> () -> Void)),
            let swizzled = class_getInstanceMethod(UIStoryboardSegue.self, #selector(UIStoryboardSegue.swizzledPerform)) else {
                return
        }
        method_exchangeImplementations(swizzled, perform)
    }()

    static func swizzle() {
        _ = swizzleImplementation
    }
}
