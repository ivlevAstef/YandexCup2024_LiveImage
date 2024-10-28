//
//  LiveImageViewController.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 28.10.2024.
//

import UIKit

final class LiveImageViewController: UIViewController {

    private(set) lazy var liveImageView: LiveImageView = LiveImageView()

    var retainScreenObjects: [AnyObject] = []

    override func loadView() {
        view = liveImageView
    }
}

