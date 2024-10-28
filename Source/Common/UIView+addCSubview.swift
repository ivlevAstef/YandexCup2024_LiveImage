//
//  UIView+addCSubview.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 29.10.2024.
//

import UIKit

extension UIView {
    /// "C" - от слова constrains. Ну на snapkit он автоматически отрубает этот флаг, а тут по быстрому выкрутился так.
    func addCSubview(_ view: UIView) {
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
    }
}
