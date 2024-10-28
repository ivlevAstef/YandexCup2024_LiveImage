//
//  LiveImageView.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 28.10.2024.
//

import Foundation
import UIKit

final class LiveImageView: UIView, LiveImageViewProtocol {
    var actionSelectHandler: LiveImageActionSelectHandler? {
        get { actionPanel.tapOnAction }
        set { actionPanel.tapOnAction = newValue }
    }

    var availableActions: Set<LiveImageAction> {
        get { actionPanel.availableActions }
        set { actionPanel.availableActions = newValue }
    }

    private let actionPanel: ActionPanelView = ActionPanelView()

    init() {
        super.init(frame: .zero)

        commonInit()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        backgroundColor = Colors.backgroundColor

        addSubview(actionPanel)

        makeConstraints()
    }

    private func makeConstraints() {

        actionPanel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            actionPanel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16.0),
            actionPanel.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
            actionPanel.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
            actionPanel.heightAnchor.constraint(equalToConstant: 32.0)
        ])
    }

}
