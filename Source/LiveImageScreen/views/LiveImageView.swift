//
//  LiveImageView.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 28.10.2024.
//

import Foundation
import UIKit

final class LiveImageView: UIView, LiveImageViewProtocol {
    var action: LiveImageActionViewProtocol { actionPanel }
    var canvas: LiveImageCanvasViewProtocol { canvasView }
    var draw: LiveImageDrawViewProtocol { drawPanel }

    private let actionPanel = ActionPanelView()
    private let canvasView = CanvasView()
    private let drawPanel = DrawPanelView()

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

        addCSubview(actionPanel)
        addCSubview(canvasView)
        addCSubview(drawPanel)

        makeConstraints()

        drawPanel.setSuperView(self)
    }
    

    private func makeConstraints() {
        NSLayoutConstraint.activate([
            actionPanel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16.0),
            actionPanel.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
            actionPanel.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
            actionPanel.heightAnchor.constraint(equalToConstant: 32.0),

            canvasView.topAnchor.constraint(equalTo: actionPanel.bottomAnchor, constant: 32.0),
            canvasView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
            canvasView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
            canvasView.bottomAnchor.constraint(equalTo: drawPanel.topAnchor, constant: -22.0),

            drawPanel.leftAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.leftAnchor),
            drawPanel.rightAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.rightAnchor),
            drawPanel.centerXAnchor.constraint(equalTo: centerXAnchor),
            drawPanel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            drawPanel.heightAnchor.constraint(equalToConstant: 32.0)
        ])
    }

}
