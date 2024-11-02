//
//  LiveImagePresenter.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 28.10.2024.
//

import Foundation

typealias LiveImageActionSelectHandler = (_ action: LiveImageAction) -> Void
typealias LiveImagePlayWithSpeedHandler = (_ speed: PlaySpeed) -> Void
protocol LiveImageActionViewProtocol: AnyObject {
    var selectActionHandler: LiveImageActionSelectHandler? { get set }
    var playWithSpeedHandler: LiveImagePlayWithSpeedHandler? { get set }

    var availableActions: Set<LiveImageAction> { get set }
    var framesIsShown: Bool { get set }
}

typealias LiveImageInstrumentSelectHandler = (_ instrument: DrawInstrument) -> Void
typealias LiveImageColorSelectHandler = (_ color: DrawColor) -> Void
typealias LiveImageShowMoreColorHandler = () -> Void
protocol LiveImageDrawViewProtocol: AnyObject {
    var selectInstrumentHandler: LiveImageInstrumentSelectHandler? { get set }
    var selectColorHandler: LiveImageColorSelectHandler? { get set }
    var showMoreColorsHandler: LiveImageShowMoreColorHandler? { get set }

    var selectedInstrument: DrawInstrument { get set }
    var selectedColor: DrawColor { get set }
    var selectedWidth: CGFloat { get set }

    var shownColors: [DrawColor] { get set }

    func setEnable(_ enable: Bool)

    func hidePopup()
}

typealias LiveImageRecordMakedHandler = (Canvas.Record) -> Void
protocol LiveImageCanvasViewProtocol: AnyObject {
    var recordMakedHandler: LiveImageRecordMakedHandler? { get set }

    var instrument: DrawInstrument { get set }
    var width: CGFloat { get set }
    var color: DrawColor { get set }
    var fps: Int { get set }

    var prevFrameRecord: Canvas.Record? { get set }
    var currentRecord: Canvas.Record? { get set }

    var canvasSize: CanvasSize { get }

    func runPlay(_ records: [Canvas.Record])
    func stopPlay()
}

typealias LiveImageSelectedFrameChangedHandler = (Int) -> Void
typealias LiveImageDeleteFrameHandler = (Int) -> Void
typealias LiveImageDublicateFrameHandler = (Int) -> Void
typealias LiveImageAddFrameHandler = () -> Void
typealias LiveImageGenerateFramesHandler = () -> Void
protocol LiveImageFramesViewProtocol: AnyObject {
    var selectedFrameChangedHandler: LiveImageSelectedFrameChangedHandler? { get set }
    var deleteFrameHandler: LiveImageDeleteFrameHandler? { get set }
    var dublicateFrameHandler: LiveImageDublicateFrameHandler? { get set }
    var addFrameHandler: LiveImageAddFrameHandler? { get set }
    var generateFramesHandler: LiveImageGenerateFramesHandler? { get set }

    var selectedFrameIndex: Int { get set }

    func update(recordOfFrames: [Canvas.Record], canvasSize: CanvasSize)

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
    private let shareGifPresenter: LiveImageShareGifPresenter
    private let generatorPresenter: LiveImageGeneratorPresenter
    private let colorPickerPresenter: LiveImageColorPickerPresenter

    private var canvas: Canvas = Canvas()

    private var isPlaying: Bool = false

    init(view: LiveImageViewProtocol,
         shareGifPresenter: LiveImageShareGifPresenter,
         generatorPresenter: LiveImageGeneratorPresenter,
         colorPickerPresenter: LiveImageColorPickerPresenter) {
        self.view = view
        self.shareGifPresenter = shareGifPresenter
        self.generatorPresenter = generatorPresenter
        self.colorPickerPresenter = colorPickerPresenter

        // Начальное состояние
        view.draw.selectedInstrument = .pencil
        view.draw.selectedWidth = 5.0
        colorPickerPresenter.currentColor = .black

        subscribe()
        updateUI()
    }

    private func subscribe() {
        subscribeActions()
        subscribeDraw()
        subscribeFrames()

        shareGifPresenter.currentRecordInfoProvider = { [weak self] in
            guard let self else {
                return nil
            }
            return (self.view.canvas.canvasSize, self.canvas.anyRecords)
        }
    }

    private func subscribeActions() {
        view.action.selectActionHandler = { [weak self] action in
            log.info("Tap on action: \(action)")
            self?.processAction(action)
        }
        view.action.playWithSpeedHandler = { [weak self] speed in
            self?.play(speed: speed)
            self?.updateUI()
        }
    }

    private func subscribeDraw() {
        view.draw.selectInstrumentHandler = { [weak self] instrument in
            log.info("Tap on instument: \(instrument)")
            self?.view.draw.selectedInstrument = instrument
            self?.updateUI()
        }
        view.draw.selectColorHandler = { [weak self] color in
            log.info("Tap on color: \(color)")
            self?.colorPickerPresenter.currentColor = color
            self?.updateColors()
        }
        view.draw.showMoreColorsHandler = { [weak self] in
            self?.colorPickerPresenter.showColorPicker(colorSelectedHandler: { color in
                self?.colorPickerPresenter.currentColor = color
                self?.updateColors()
            })
        }

        view.canvas.recordMakedHandler = { [weak self] record in
            log.info("Draw new record")
            self?.canvas.currentFrame.addRecord(record)
            self?.updateUI()
        }
    }

    private func subscribeFrames() {
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
            self?.generateFrames()
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
        case .dublicateFrame:
            canvas.dublicateFrame(from: canvas.currentFrameIndex)
        case .generateFrames:
            generateFrames()
            return
        case .removeFrame:
            canvas.removeFrame()
        case .removeAllFrames:
            canvas = Canvas()
        case .toggleFrames:
            if view.action.framesIsShown {
                hideFramesView()
            } else {
                showFramesView()
            }
        case .play:
            play(speed: .normal)
        case .pause:
            stop()
        }

        updateUI()
    }

    private func updateUI() {
        updateColors()
        view.canvas.instrument = view.draw.selectedInstrument
        if view.draw.selectedInstrument == .erase { // Чтобы стирать было удобней, пока нет выбора ширины.
            view.canvas.width = view.draw.selectedWidth * 2
        } else {
            view.canvas.width = view.draw.selectedWidth
        }

        view.canvas.prevFrameRecord = canvas.prevFrame?.currentRecord
        view.canvas.currentRecord = canvas.currentFrame.currentRecord

        if view.action.framesIsShown {
            view.frames.update(recordOfFrames: canvas.anyRecords, canvasSize: view.canvas.canvasSize)
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
            availableActions.insert(.removeAllFrames)
            availableActions.insert(.play)
        }
        availableActions.insert(.addFrame)
        availableActions.insert(.generateFrames)
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

    private func play(speed: PlaySpeed) {
        if isPlaying {
            return
        }

        isPlaying = true
        view.canvas.fps = speed.fps
        view.canvas.runPlay(canvas.recordsForPlay)
        if view.action.framesIsShown {
            hideFramesView()
        }
    }

    private func stop() {
        if !isPlaying {
            return
        }
        
        isPlaying = false
        view.canvas.stopPlay()
    }

    private func generateFrames() {
        log.info("generate frames")
        generatorPresenter.generate(canvasSize: view.canvas.canvasSize, success: { [weak self] records in
            log.info("generate \(records.count) frames success")
            self?.canvas.addFrames(by: records)
            self?.updateUI()
        })
    }

    private func updateColors() {
        // colorPickerPresenter.currentColor - это считается основным, от него цвет раскидываем в другие места.

        view.canvas.color = colorPickerPresenter.currentColor
        view.draw.selectedColor = colorPickerPresenter.currentColor
        view.draw.shownColors = colorPickerPresenter.colorHistory
    }
}
