//
//  LiveImageColorPickerPresenter.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 01.11.2024.
//

import UIKit

protocol LiveImageColorPickerViewProtocol: AnyObject {
    /// Показывает окно с выбором цвета
    /// - Parameters:
    ///   - currentColor: текущий цвет, который будет показан в окне по умолчанию
    ///   - completion: будет вызван по закрытию окна. Важно - если пользователь не менял цвет, то color будет nil
    func showColorPicker(currentColor: UIColor, completion: @escaping (_ color: UIColor?) -> Void)
}

final class LiveImageColorPickerPresenter {
    var currentColor: UIColor = .black {
        didSet {
            log.info("change color: \(currentColor)")
            updateColorHistory(newColor: currentColor)
        }
    }
    private(set) var colorHistory: [UIColor] = [.black, .red, .blue, .green]

    private let view: LiveImageColorPickerViewProtocol

    init(view: LiveImageColorPickerViewProtocol) {
        self.view = view
    }

    func showColorPicker(colorSelectedHandler: @escaping (UIColor) -> Void) {
        view.showColorPicker(currentColor: .black) { [weak self] color in
            guard let color else {
                log.info("color no selected")
                return
            }
            log.info("select new color: \(color)")
            self?.updateColorHistory(newColor: color)
            colorSelectedHandler(color)
        }
    }

    private func updateColorHistory(newColor: UIColor) {
        colorHistory.removeAll(where: { newColor.hexColor == $0.hexColor })
        colorHistory.insert(newColor, at: 0)

        colorHistory = Array(colorHistory.prefix(12))
    }
}
