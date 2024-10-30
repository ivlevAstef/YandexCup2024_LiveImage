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

typealias LiveImageSelectedFrameChangedHandler = (Int) -> Void
typealias LiveImageDeleteFrameHandler = (Int) -> Void
typealias LiveImageDublicateFrameHandler = (Int) -> Void
typealias LiveImageAddFrameHandler = () -> Void
typealias LiveImageGenerateFramesHandler = () -> Void

protocol LiveImageActionViewProtocol: AnyObject {
    var selectActionHandler: LiveImageActionSelectHandler? { get set }
    var availableActions: Set<LiveImageAction> { get set }

    var framesIsShown: Bool { get set }
}

protocol LiveImageDrawViewProtocol: AnyObject {
    var selectInstrumentHandler: LiveImageInstrumentSelectHandler? { get set }
    var selectColorHandler: LiveImageColorSelectHandler? { get set }

    var selectedInstrument: DrawInstrument { get set }
    var selectedColor: DrawColor { get set }
    var selectedWidth: CGFloat { get set }

    func setEnable(_ enable: Bool)

    func hidePopup()
}

protocol LiveImageCanvasViewProtocol: AnyObject {
    var recordMakedHandler: LiveImageRecordMakedHandler? { get set }

    var instrument: DrawInstrument { get set }
    var width: CGFloat { get set }
    var color: DrawColor { get set }

    var prevFrameRecord: Canvas.Record? { get set }
    var currentRecord: Canvas.Record? { get set }

    var emptyRecord: Canvas.Record { get }

    func runPlay(_ records: [Canvas.Record])
    func stopPlay()
}

protocol LiveImageFramesViewProtocol: AnyObject {
    var selectedFrameChangedHandler: LiveImageSelectedFrameChangedHandler? { get set }
    var deleteFrameHandler: LiveImageDeleteFrameHandler? { get set }
    var dublicateFrameHandler: LiveImageDublicateFrameHandler? { get set }
    var addFrameHandler: LiveImageAddFrameHandler? { get set }
    var generateFramesHandler: LiveImageGenerateFramesHandler? { get set }

    var recordOfFrames: [Canvas.Record] { get set }
    var selectedFrameIndex: Int { get set }

    func show()
    func hide()
}

protocol LiveImageViewProtocol: AnyObject {
    var action: LiveImageActionViewProtocol { get }
    var canvas: LiveImageCanvasViewProtocol { get }
    var draw: LiveImageDrawViewProtocol { get }
    var frames: LiveImageFramesViewProtocol { get }
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

        subscribe()
        updateUI()
    }

    private func subscribe() {
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
            log.info("Draw new record")
            self?.canvas.currentFrame.addRecord(record)
            self?.updateUI()
        }

        view.frames.selectedFrameChangedHandler = { [weak self] newIndex in
            log.info("change current frame on \(newIndex)")
            self?.canvas.changeFrameIndex(newIndex)
            self?.updateUI()
        }
        view.frames.deleteFrameHandler = { [weak self] deleteIndex in
            log.info("delete frame on \(deleteIndex)")
            self?.canvas.removeFrame(in: deleteIndex)
            self?.updateUI()
        }
        view.frames.dublicateFrameHandler = { [weak self] dublicateIndex in
            log.info("dublicate frame from \(dublicateIndex)")
            self?.canvas.dublicateFrame(from: dublicateIndex)
            self?.updateUI()
        }
        view.frames.addFrameHandler = { [weak self] in
            log.info("add frame")
            self?.canvas.addFrame()
            self?.updateUI()
        }
        view.frames.generateFramesHandler = { [weak self] in
            log.info("generate frames")
            // TODO: generate
        }
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
        case .toggleFrames:
            if view.action.framesIsShown {
                hideFramesView()
            } else {
                showFramesView()
            }
        case .play:
            isPlaying = true
            view.canvas.runPlay(canvas.recordsForPlay(emptyRecord: view.canvas.emptyRecord))
            if view.action.framesIsShown {
                hideFramesView()
            }
        case .pause:
            isPlaying = false
            view.canvas.stopPlay()
        }

        updateUI()
    }

    private func updateUI() {
        view.canvas.instrument = view.draw.selectedInstrument
        view.canvas.color = view.draw.selectedColor
        if view.draw.selectedInstrument == .erase { // Чтобы стирать было удобней, пока нет выбора ширины.
            view.canvas.width = view.draw.selectedWidth * 2
        } else {
            view.canvas.width = view.draw.selectedWidth
        }

        view.canvas.prevFrameRecord = canvas.prevFrame?.currentRecord
        view.canvas.currentRecord = canvas.currentFrame.currentRecord

        if view.action.framesIsShown {
            view.frames.recordOfFrames = canvas.anyRecords(emptyRecord: view.canvas.emptyRecord)
            view.frames.selectedFrameIndex = canvas.currentFrameIndex
        }

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
        availableActions.insert(.toggleFrames)

        view.action.availableActions = availableActions
    }

    private func showFramesView() {
        view.action.framesIsShown = true
        view.draw.hidePopup()
        view.frames.show()
    }

    private func hideFramesView() {
        view.action.framesIsShown = false
        view.frames.hide()
    }
}
