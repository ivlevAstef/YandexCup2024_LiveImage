//
//  LiveImageRouter.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 28.10.2024.
//

import Foundation
import UIKit

final class LiveImageRouter {
    private(set) lazy var navigationController = UINavigationController(nibName: nil, bundle: nil)

    init() {
        navigationController.setNavigationBarHidden(true, animated: false)
    }

    func start() {
        let rootVC = makeLiveImageViewScreen()
        navigationController.setViewControllers([rootVC], animated: false)
    }

    private func makeLiveImageViewScreen() -> LiveImageViewController {
        let vc = LiveImageViewController(nibName: nil, bundle: nil)
        let presenter = LiveImagePresenter(view: vc.liveImageView)

        vc.retainScreenObjects = [self, presenter]

        return vc
    }
}