//
//  DefaultImageButton.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 28.10.2024.
//

import UIKit

class DefaultImageButton: UIButton {
    init(image: UIImage?, size: CGFloat = 32.0) {
        super.init(frame: .zero)

        setImage(image?.withTintColor(Colors.textColor), for: .normal)
        setImage(image?.withTintColor(Colors.selectColor), for: .selected)
        setImage(image?.withTintColor(Colors.selectColor), for: .highlighted)
        setImage(image?.withTintColor(Colors.unaccentColor), for: .disabled)

        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size),
            heightAnchor.constraint(equalToConstant: size)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
