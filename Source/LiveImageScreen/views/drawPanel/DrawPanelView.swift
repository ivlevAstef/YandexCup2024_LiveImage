//
//  DrawPanelView.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 28.10.2024.
//

import Foundation
import UIKit

final class DrawPanelView: UIView, LiveImageDrawViewProtocol {
    var selectInstrumentHandler: LiveImageInstrumentSelectHandler? {
        get { instrumentsView.selectInstrumentHandler }
        set { instrumentsView.selectInstrumentHandler = newValue }
    }
    var selectColorHandler: LiveImageColorSelectHandler? {
        get { selectedColorView.selectColorHandler }
        set { selectedColorView.selectColorHandler = newValue }
    }
    var showMoreColorsHandler: LiveImageShowMoreColorHandler? {
        get { selectedColorView.showMoreColorsHandler }
        set { selectedColorView.showMoreColorsHandler = newValue }
    }

    var selectedInstrument: DrawInstrument {
        get { instrumentsView.selectedInstrument }
        set { instrumentsView.selectedInstrument = newValue }
    }
    var selectedColor: DrawColor {
        get { selectedColorView.selectedColor }
        set { selectedColorView.selectedColor = newValue }
    }
    var selectedWidth: CGFloat = 5.0

    var shownColors: [DrawColor] {
        get { selectedColorView.shownColors }
        set { selectedColorView.shownColors = newValue }
    }

    private let instrumentsView = InstrumentsView()
    private let selectedColorView = SelectedColorView()

    init() {
        super.init(frame: .zero)

        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSuperView(_ superView: UIView) {
        instrumentsView.setParentView(self, superView: superView)
        selectedColorView.setParentView(self, superView: superView)
    }

    func setEnable(_ enable: Bool) {
        isUserInteractionEnabled = enable
        instrumentsView.setEnable(enable)

        if !enable {
            hidePopup()
        }
    }

    func hidePopup() {
        selectedColorView.hidePopup()
        instrumentsView.hidePopup()
    }

    private func commonInit() {
        addCSubview(instrumentsView)
        addCSubview(selectedColorView)

        makeConstraints()
    }

    private func makeConstraints() {
        let space = 16.0
        NSLayoutConstraint.activate([
            instrumentsView.leftAnchor.constraint(equalTo: leftAnchor),
            instrumentsView.topAnchor.constraint(equalTo: topAnchor),
            instrumentsView.bottomAnchor.constraint(equalTo: bottomAnchor),

            selectedColorView.leftAnchor.constraint(equalTo: instrumentsView.rightAnchor, constant: space),
            selectedColorView.centerYAnchor.constraint(equalTo: centerYAnchor),
            selectedColorView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
}
