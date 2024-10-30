//
//  LiveImageViewController.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 28.10.2024.
//

import UIKit

final class LiveImageViewController: UIViewController, LiveImageGeneratorViewProtocol {

    private(set) lazy var liveImageView = LiveImageView()

    var retainScreenObjects: [AnyObject] = []

    override func loadView() {
        view = liveImageView
    }

    func showWriteHowManyFramesGenerate(success successHandler: @escaping (Int) -> Void) {
        let alertController = UIAlertController(title: "Generate Frames",
                                                message: "Please enter how many frames you need to generate",
                                                preferredStyle: .alert)

        var framesCount: Int = 0

        let generateAction = UIAlertAction(title: "Generate", style: .default) { [weak alertController] _ in
            if framesCount > 0 {
                successHandler(framesCount)
            }
            alertController?.dismiss(animated: true)
        }
        generateAction.isEnabled = false

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak alertController] _ in
            alertController?.dismiss(animated: true)
        }

        alertController.addTextField { textField in
            textField.text = ""
            textField.keyboardType = .numberPad
            textField.textColor = Colors.textColor

            textField.addAction(UIAction { [weak textField] _ in
                if let number = textField?.text.flatMap({ Int($0) }), number > 0 {
                    framesCount = number
                    generateAction.isEnabled = true
                } else {
                    generateAction.isEnabled = false
                }
            }, for: .editingChanged)
        }
        alertController.addAction(generateAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }
}

