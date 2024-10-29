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

typealias LiveImageFigureMakedHandler = (CanvasFigure) -> Void

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

protocol LiveImageCanvasViewProtocol: AnyObject {
    var figureMakedHandler: LiveImageFigureMakedHandler? { get set }

    var instrument: DrawInstrument { get set }
    var width: CGFloat { get set }
    var color: DrawColor { get set }
}

protocol LiveImageViewProtocol: AnyObject {
    var action: LiveImageActionViewProtocol { get }
    var canvas: LiveImageCanvasViewProtocol { get }
    var draw: LiveImageDrawViewProtocol { get }
}

final class LiveImagePresenter {
    private let view: LiveImageViewProtocol

    init(view: LiveImageViewProtocol) {
        self.view = view

        view.action.selectActionHandler = { [weak self] action in
            log.info("Tap on action: \(action)")
        }
        view.action.availableActions = [.removeFrame, .addFrame, .showFrames, .play]

        view.draw.selectedInstrument = .pencil
        view.draw.selectedColor = .blue

        view.draw.selectInstrumentHandler = { [weak self] instrument in
            log.info("Tap on instument: \(instrument)")
            self?.view.draw.selectedInstrument = instrument
            self?.view.canvas.instrument = instrument
        }

        view.draw.selectColorHandler = { [weak self] color in
            log.info("Tap on color: \(color)")
            self?.view.draw.selectedColor = color
            self?.view.canvas.color = color
        }
    }
}
