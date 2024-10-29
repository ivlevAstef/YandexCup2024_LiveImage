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

typealias LiveImageRecordMakedHandler = (Canvas.Record) -> Void

protocol LiveImageActionViewProtocol: AnyObject {
    var selectActionHandler: LiveImageActionSelectHandler? { get set }
    var availableActions: Set<LiveImageAction> { get set }
}

protocol LiveImageDrawViewProtocol: AnyObject {
    var selectInstrumentHandler: LiveImageInstrumentSelectHandler? { get set }
    var selectColorHandler: LiveImageColorSelectHandler? { get set }

    var selectedInstrument: DrawInstrument { get set }
    var selectedColor: DrawColor { get set }
    var selectedWidth: CGFloat { get set }

    func setEnable(_ enable: Bool)
}

protocol LiveImageCanvasViewProtocol: AnyObject {
    var recordMakedHandler: LiveImageRecordMakedHandler? { get set }

    var instrument: DrawInstrument { get set }
    var width: CGFloat { get set }
    var color: DrawColor { get set }

    var prevFrameRecord: Canvas.Record? { get set }
    var currentRecord: Canvas.Record? { get set }

    func runPlay(_ records: [Canvas.Record])
    func stopPlay()
}

protocol LiveImageViewProtocol: AnyObject {
    var action: LiveImageActionViewProtocol { get }
    var canvas: LiveImageCanvasViewProtocol { get }
    var draw: LiveImageDrawViewProtocol { get }
}

final class LiveImagePresenter {
    private let view: LiveImageViewProtocol

    private var canvas: Canvas = Canvas()

    private var isPlaying: Bool = false

    init(view: LiveImageViewProtocol) {
        self.view = view

        // Начальное состояние
        view.draw.selectedInstrument = .pencil
        view.draw.selectedWidth = 5.0
        view.draw.selectedColor = .black

        view.action.selectActionHandler = { [weak self] action in
            log.info("Tap on action: \(action)")
            self?.processAction(action)
        }

        view.draw.selectInstrumentHandler = { [weak self] instrument in
            log.info("Tap on instument: \(instrument)")
            self?.view.draw.selectedInstrument = instrument
            self?.updateUI()
        }
        view.draw.selectColorHandler = { [weak self] color in
            log.info("Tap on color: \(color)")
            self?.view.draw.selectedColor = color
            self?.updateUI()
        }

        view.canvas.recordMakedHandler = { [weak self] record in
            if let self {
                self.canvas.currentFrame.addRecord(record)
                self.updateUI()
            }
        }

        updateUI()
    }

    private func processAction(_ action: LiveImageAction) {
        switch action {
        case .undo:
            canvas.currentFrame.undo()
        case .redo:
            canvas.currentFrame.redo()
        case .addFrame:
            canvas.addFrame()
        case .removeFrame:
            canvas.removeFrame()
        case .play:
            isPlaying = true
            view.canvas.runPlay(canvas.recordsForPlay)
        case .pause:
            isPlaying = false
            view.canvas.stopPlay()
        default:
            break
        }

        updateUI()
    }

    private func updateUI() {
        view.canvas.instrument = view.draw.selectedInstrument
        view.canvas.color = view.draw.selectedColor
        view.canvas.width = view.draw.selectedWidth

        view.canvas.prevFrameRecord = canvas.prevFrame?.currentRecord
        view.canvas.currentRecord = canvas.currentFrame.currentRecord

        view.draw.setEnable(!isPlaying)

        updateAvailableActions()
    }

    private func updateAvailableActions() {
        if isPlaying {
            view.action.availableActions = [.pause]
            return
        }

        var availableActions: Set<LiveImageAction> = []
        if canvas.currentFrame.canUndo {
            availableActions.insert(.undo)
        }
        if canvas.currentFrame.canRedo {
            availableActions.insert(.redo)
        }
        if canvas.haveMoreFrames {
            availableActions.insert(.removeFrame)
            availableActions.insert(.play)
        }
        availableActions.insert(.addFrame)

        view.action.availableActions = availableActions
    }
}
