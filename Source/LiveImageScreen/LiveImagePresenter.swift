//
//  LiveImagePresenter.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 28.10.2024.
//

import Foundation

typealias LiveImageActionSelectHandler = (_ action: LiveImageAction) -> Void
typealias LiveImageInstrumentSelectHandler = (_ instrument: DrawInstrument) -> Void
typealias LiveImageColorSelectHandler = (_ color: DrawColor) -> Void

protocol LiveImageActionViewProtocol: AnyObject {
    var selectActionHandler: LiveImageActionSelectHandler? { get set }
    var availableActions: Set<LiveImageAction> { get set }
}

protocol LiveImageDrawViewProtocol: AnyObject {
    var selectInstrumentHandler: LiveImageInstrumentSelectHandler? { get set }
    var selectColorHandler: LiveImageColorSelectHandler? { get set }

    var selectedInstrument: DrawInstrument? { get set }
    var selectedColor: DrawColor? { get set }
}

protocol LiveImageViewProtocol: AnyObject {
    var actionView: LiveImageActionViewProtocol { get }
    var drawView: LiveImageDrawViewProtocol { get }
}

final class LiveImagePresenter {
    private let view: LiveImageViewProtocol

    init(view: LiveImageViewProtocol) {
        self.view = view

        view.actionView.selectActionHandler = { [weak self] action in
            log.info("Tap on action: \(action)")
        }
        view.actionView.availableActions = [.removeFrame, .addFrame, .showFrames, .play]

        view.drawView.selectedInstrument = .pencil
        view.drawView.selectedColor = .blue

        view.drawView.selectInstrumentHandler = { [weak self] instrument in
            log.info("Tap on instument: \(instrument)")
            self?.view.drawView.selectedInstrument = instrument
        }

        view.drawView.selectColorHandler = { [weak self] color in
            log.info("Tap on color: \(color)")
            self?.view.drawView.selectedColor = color
        }
    }
}
