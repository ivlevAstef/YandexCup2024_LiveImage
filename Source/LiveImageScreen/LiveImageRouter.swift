//
//  LiveImageRouter.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 28.10.2024.
//

import Foundation
import UIKit

final class LiveImageRouter {
    let navigationController: UINavigationController
    private let rootViewController: LiveImageViewController

    init() {
        let rootVC = LiveImageViewController(nibName: nil, bundle: nil)
        self.navigationController = UINavigationController(rootViewController: rootVC)
        self.rootViewController = rootVC
    }

    func start() {

    }
}
