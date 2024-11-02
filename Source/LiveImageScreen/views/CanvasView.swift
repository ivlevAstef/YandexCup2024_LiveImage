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
            prevFrameRecordView.image = prevFrameRecord?.toImage
        }
    }

    var currentRecord: Canvas.Record? {
        didSet {
            currentImage = currentRecord?.toImage
            currentRecordView.image = currentImage
        }
    }

    var canvasSize: CanvasSize {
        return CanvasSize(size: bounds.size, scale: UIScreen.main.scale)
    }

    var emptyRecord: Canvas.Record { return generateEmptyRecord() }

    private var currentImage: UIImage?
    private var currentPainter: EditableObjectPainter?

    private let backgroundImageView = UIImageView(image: Consts.backgroundImage)
    private let prevFrameRecordView = UIImageView(image: nil)
    private let currentRecordView = UIImageView(image: nil)

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
        currentRecordView.image = records[recordIndex].toImage

        playTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / Double(fps), repeats: true, block: { [weak self] _ in
            recordIndex = (recordIndex + 1) % records.count
            if let self {
                self.currentRecordView.image = records[recordIndex].toImage
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
        currentPainter?.clean()
        currentPainter?.movePoint(newTouchPoint)
        updateDrawLayer()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let newTouchPoint = touches.first?.location(in: self) else {
            return
        }
        currentPainter?.movePoint(newTouchPoint)
        updateDrawLayer()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let newRecord = flattenToRecord()
        recordMakedHandler?(newRecord)
        currentPainter?.clean()
        updateDrawLayer()
    }

    private func commonInit() {
        backgroundColor = Colors.backgroundColor
        addCSubview(backgroundImageView)
        addCSubview(prevFrameRecordView)
        addCSubview(currentRecordView)

        isMultipleTouchEnabled = false
        layer.cornerRadius = 20.0
        layer.cornerCurve = .continuous
        clipsToBounds = true

        prevFrameRecordView.alpha = 0.3
        backgroundImageView.contentMode = .scaleAspectFill

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
        case .circle:
            currentPainter = CirclePainter()
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
        currentRecordView.image = currentPainter?.makeImage(on: canvasSize, from: currentImage)
    }

    // MARK: Images

    private func flattenToRecord() -> Canvas.Record {
        return currentRecordView.image?.pngData() ?? generateEmptyRecord()
    }

    private func generateEmptyRecord() -> Canvas.Record {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.pngData { _ in }
    }
}
