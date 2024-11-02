//
//  CanvasView.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 29.10.2024.
//

import UIKit

private enum Consts {
    static let backgroundImage = UIImage(named: "background_draw_area")
    static let defaultFPS: Int = 60
}

final class CanvasView: UIView, LiveImageCanvasViewProtocol {
    var recordMakedHandler: LiveImageRecordMakedHandler? = nil

    var instrument: DrawInstrument = .pencil {
        didSet {
            if oldValue != instrument {
                updateCurrentPainter()
            }
        }
    }
    var width: CGFloat = 5.0 {
        didSet { updateCurrentPainterConfiguration() }
    }
    var color: DrawColor = .black {
        didSet { updateCurrentPainterConfiguration() }
    }

    var fps: Int = Consts.defaultFPS

    var prevFrameRecord: Canvas.Record? {
        didSet {
            prevFrameRecordView.image = prevFrameRecord?.makeImage(canvasSize: canvasSize)
        }
    }

    var currentRecord: Canvas.Record? {
        didSet {
            currentImage = currentRecord?.makeImage(canvasSize: canvasSize)
            currentRecordView.image = currentImage
        }
    }

    var canvasSize: CanvasSize {
        return CanvasSize(size: bounds.size, scale: UIScreen.main.scale)
    }

    private var currentImage: UIImage?
    private var currentPainter: EditableObjectPainter?

    private let backgroundImageView = UIImageView(image: Consts.backgroundImage)
    private let prevFrameRecordView = UIImageView(image: nil)
    private let currentRecordView = UIImageView(image: nil)

    private var initialTouchPosition: CGPoint = .zero
    private let drawView = UIView(frame: .zero)
    private let drawLayer = CAShapeLayer()

    private var playTimer: Timer?

    init() {
        super.init(frame: .zero)

        commonInit()
    }

    deinit {
        playTimer?.invalidate()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func runPlay(_ records: [Canvas.Record]) {
        if records.count < 2 {
            log.assert("can't run play because no more records")
            return
        }

        playTimer?.invalidate()
        playTimer = nil

        prevFrameRecordView.isHidden = true
        isUserInteractionEnabled = false

        var recordIndex = 0
        currentRecordView.image = records[recordIndex].makeImage(canvasSize: canvasSize)

        playTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / Double(fps), repeats: true, block: { [weak self] _ in
            recordIndex = (recordIndex + 1) % records.count
            if let self {
                self.currentRecordView.image = records[recordIndex].makeImage(canvasSize: canvasSize)
            }
        })
    }

    func stopPlay() {
        prevFrameRecordView.isHidden = false
        isUserInteractionEnabled = true

        playTimer?.invalidate()
        playTimer = nil
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let newTouchPoint = touches.first?.location(in: self) else {
            return
        }
        initialTouchPosition = newTouchPoint
        currentPainter?.clean()
        currentPainter?.movePoint(newTouchPoint, initialPoint: initialTouchPosition)
        updateDrawLayer()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let newTouchPoint = touches.first?.location(in: self) else {
            return
        }
        currentPainter?.movePoint(newTouchPoint, initialPoint: initialTouchPosition)
        updateDrawLayer()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let currentPainter else {
            return
        }

        let newRecord = Canvas.Record(painter: currentPainter, oldState: currentImage?.pngData())
        recordMakedHandler?(newRecord)
        self.currentPainter?.clean()
        updateDrawLayer()
    }

    private func commonInit() {
        backgroundColor = Colors.backgroundColor
        addCSubview(backgroundImageView)
        addCSubview(prevFrameRecordView)
        addCSubview(currentRecordView)
        addCSubview(drawView)

        isMultipleTouchEnabled = false
        layer.cornerRadius = 20.0
        layer.cornerCurve = .continuous
        clipsToBounds = true

        prevFrameRecordView.alpha = 0.3
        backgroundImageView.contentMode = .scaleAspectFill

        drawView.layer.addSublayer(drawLayer)
        drawView.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        drawView.frame = .zero // при отрисовки он посчитается
        drawLayer.contentsScale = canvasSize.scale
        drawLayer.fillColor = UIColor.clear.cgColor
        drawLayer.strokeColor = UIColor.clear.cgColor

        updateCurrentPainter()

        makeConstraints()
    }

    private func makeConstraints() {
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.leftAnchor.constraint(equalTo: leftAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: rightAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        NSLayoutConstraint.activate([
            prevFrameRecordView.topAnchor.constraint(equalTo: topAnchor),
            prevFrameRecordView.leftAnchor.constraint(equalTo: leftAnchor),
            prevFrameRecordView.rightAnchor.constraint(equalTo: rightAnchor),
            prevFrameRecordView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        NSLayoutConstraint.activate([
            currentRecordView.topAnchor.constraint(equalTo: topAnchor),
            currentRecordView.leftAnchor.constraint(equalTo: leftAnchor),
            currentRecordView.rightAnchor.constraint(equalTo: rightAnchor),
            currentRecordView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // MARK: - Draw

    private func updateCurrentPainter() {
        switch instrument {
        case .pencil:
            currentPainter = PencilPainter()
        case .brush:
            currentPainter = BrushPainter()
        case .erase:
            currentPainter = ErasePainter()
        case .rectangle:
            currentPainter = RectanglePainter()
        case .oval:
            currentPainter = OvalPainter()
        case .triangle:
            currentPainter = TrianglePainter()
        case .arrow:
            currentPainter = ArrowPainter()
        }

        updateCurrentPainterConfiguration()
    }

    private func updateCurrentPainterConfiguration() {
        currentPainter?.lineWidth = width
        currentPainter?.color = color
    }

    private func updateDrawLayer() {
        if let optimizedPainter = currentPainter as? OptimizeLayoutObjectPainter {
            currentRecordView.image = currentImage
            optimizedPainter.fillLayer(drawLayer)
            drawView.frame = optimizedPainter.layerFrame()
        } else {
            currentRecordView.image = currentPainter?.makeImage(on: canvasSize, from: currentImage)
        }
    }
}
