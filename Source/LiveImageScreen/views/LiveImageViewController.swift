//
//  LiveImageViewController.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 28.10.2024.
//

import UIKit
import Combine

final class LiveImageViewController: UIViewController {
    var shouldShareHandler: LiveImageShouldShareGifHandler? { // LiveImageShareGifViewProtocol
        get { liveImageView.shouldShareHandler }
        set { liveImageView.shouldShareHandler = newValue }
    }

    private(set) lazy var liveImageView = LiveImageView()

    var retainScreenObjects: [AnyObject] = []

    private var progressAlertController: UIAlertController?

    override func loadView() {
        view = liveImageView
    }

    // MARK: - For general view protocols

    func showProgress(text: String) {
        log.assert(Thread.isMainThread, "support show progress only from main thread")
        view.isUserInteractionEnabled = false

        let alertController = UIAlertController(title: text, message: nil, preferredStyle: .alert)
        progressAlertController = alertController

        let indicatorView = UIActivityIndicatorView(frame: alertController.view.bounds)
        alertController.view.addCSubview(indicatorView)
        indicatorView.isUserInteractionEnabled = false
        NSLayoutConstraint.activate([
            indicatorView.centerYAnchor.constraint(equalTo: alertController.view.centerYAnchor),
            indicatorView.centerXAnchor.constraint(equalTo: alertController.view.centerXAnchor, constant: 75.0)
        ])
        indicatorView.startAnimating()

        present(alertController, animated: true)
    }

    func endProgress() {
        endProgress(completion: nil)
    }

    func endProgress(completion: (() -> Void)?) {
        log.assert(Thread.isMainThread, "support hide progress only from main thread")
        view.isUserInteractionEnabled = true

        progressAlertController?.dismiss(animated: true, completion: completion)
        progressAlertController = nil
    }
}

extension LiveImageViewController: LiveImageGeneratorViewProtocol {
    func showWriteHowManyFramesGenerate(success successHandler: @escaping (Int) -> Void) {
        log.assert(Thread.isMainThread, "support show write how many frames generate only from main thread")

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

extension LiveImageViewController: LiveImageShareGifViewProtocol {
    func showShareMenu(for fileURL: URL) {
        log.assert(Thread.isMainThread, "support show share menu only from main thread")
        let filesToShare: [Any] = [fileURL]

        let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in

        }

        present(activityViewController, animated: true)
    }
}


extension LiveImageViewController: LiveImageColorPickerViewProtocol {
    func showColorPicker(currentColor: UIColor, completion: @escaping (UIColor?) -> Void) {
        let picker = UIColorPickerViewController()
        picker.supportsAlpha = false
        picker.selectedColor = currentColor

        var selectedColor: UIColor?
        var colorPickerCancellable: AnyCancellable? = picker.publisher(for: \.selectedColor).dropFirst().sink { color in
            selectedColor = color
        }

        var retainedDelegate: UIAdaptivePresentationControllerDelegate?
        let delegate = PickerDelegateImpl {
            retainedDelegate = nil
            _ = retainedDelegate
            colorPickerCancellable = nil
            _ = colorPickerCancellable

            completion(selectedColor)
        }
        retainedDelegate = delegate
        picker.delegate = delegate
        picker.presentationController?.delegate = delegate

        present(picker, animated: true)
    }
}

private final class PickerDelegateImpl: NSObject, UIAdaptivePresentationControllerDelegate, UIColorPickerViewControllerDelegate {
    private let completion: () -> Void

    init(completion: @escaping () -> Void) {
        self.completion = completion
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        completion()
    }

    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        completion()
    }
}
