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
    var frames: LiveImageFramesViewProtocol { framesPanel }

    var shouldShareHandler: LiveImageShouldShareGifHandler?

    var lineWidthChangedHandler: LiveImageLineWidthChangedHandler? {
        get { sliderLineWidthView.widthChanged }
        set { sliderLineWidthView.widthChanged = newValue }
    }

    var lineWidth: CGFloat {
        get { sliderLineWidthView.selectedWidth }
        set { sliderLineWidthView.selectedWidth = newValue }
    }

    private let actionPanel = ActionPanelView()
    private let canvasView = CanvasView()
    private let shareButton = DefaultImageButton(
        image: UIImage(systemName: "square.and.arrow.up")?.withRenderingMode(.alwaysOriginal),
        size: 40.0
    )
    private let drawPanel = DrawPanelView()
    private let framesPanel = LiveImageFramesPanelView()
    private let sliderLineWidthView = SliderLineWidthView()

    init() {
        super.init(frame: .zero)

        commonInit()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setEnable(_ enable: Bool) {
        drawPanel.setEnable(enable)
        sliderLineWidthView.setEnable(enable)
        shareButton.isEnabled = enable
    }

    private func commonInit() {
        backgroundColor = Colors.backgroundColor

        addCSubview(actionPanel)
        addCSubview(canvasView)
        addCSubview(sliderLineWidthView)
        addCSubview(shareButton)
        addCSubview(drawPanel)
        addCSubview(framesPanel)

        shareButton.addAction(UIAction { [weak self] _ in
            self?.shouldShareHandler?()
        }, for: .touchUpInside)

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

            shareButton.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 4.0),
            shareButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

            drawPanel.leftAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.leftAnchor),
            drawPanel.rightAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.rightAnchor),
            drawPanel.centerXAnchor.constraint(equalTo: centerXAnchor),
            drawPanel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            drawPanel.heightAnchor.constraint(equalToConstant: 32.0),

            framesPanel.topAnchor.constraint(equalTo: topAnchor),
            framesPanel.leftAnchor.constraint(equalTo: leftAnchor),
            framesPanel.rightAnchor.constraint(equalTo: rightAnchor),
            framesPanel.bottomAnchor.constraint(equalTo: bottomAnchor),

            sliderLineWidthView.leftAnchor.constraint(equalTo: leftAnchor),
            sliderLineWidthView.centerYAnchor.constraint(equalTo: canvasView.centerYAnchor, constant: 128.0)
        ])
    }

}
