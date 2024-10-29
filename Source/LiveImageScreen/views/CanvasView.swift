//
//  CanvasView.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 29.10.2024.
//

import UIKit

private enum Consts {
    static let backgroundImage = UIImage(named: "background_draw_area")
    static let fps: Int = 12
}

final class CanvasView: UIView, LiveImageCanvasViewProtocol {
    var recordMakedHandler: LiveImageRecordMakedHandler? = nil

    var instrument: DrawInstrument = .pencil {
        didSet { updateDrawLayerStyle() }
    }
    var width: CGFloat = 5.0 {
        didSet { updateDrawLayerStyle() }
    }
    var color: DrawColor = .black {
        didSet { updateDrawLayerStyle() }
    }

    var prevFrameRecord: Canvas.Record? {
        didSet { prevFrameRecordView.image = prevFrameRecord }
    }

    var currentRecord: Canvas.Record? {
        didSet { currentRecordView.image = currentRecord }
    }

    var emptyRecord: Canvas.Record { return emptyImage() }

    private var pathPositions: [CGPoint] = []
    private let drawLayer = CAShapeLayer()

    private let backgroundImageView = UIImageView(image: Consts.backgroundImage)
    private let drawView = UIView(frame: .zero)
    private let prevFrameRecordView = UIImageView(image: nil)
    private let currentRecordView = UIImageView(image: nil)

    private var playRecordWorkItem: DispatchWorkItem?

    init() {
        super.init(frame: .zero)

        commonInit()
    }

    deinit {
        playRecordWorkItem?.cancel()
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

        prevFrameRecordView.isHidden = true
        isUserInteractionEnabled = false

        var recordIndex = 0
        let workItem = DispatchWorkItem(block: { [weak self] in
            recordIndex = (recordIndex + 1) % records.count
            if let self, let workItem = self.playRecordWorkItem {
                currentRecordView.image = records[recordIndex]
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 / Double(Consts.fps), execute: workItem)
            }
        })
        playRecordWorkItem = workItem
        currentRecordView.image = records[recordIndex]
        DispatchQueue.main.async(execute: workItem)
    }

    func stopPlay() {
        prevFrameRecordView.isHidden = false
        isUserInteractionEnabled = true

        playRecordWorkItem?.cancel()
        playRecordWorkItem = nil
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let newTouchPoint = touches.first?.location(in: self) else {
            return
        }
        pathPositions = [newTouchPoint]
        updateDrawLayer()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let newTouchPoint = touches.first?.location(in: self) else {
            return
        }

        pathPositions.append(newTouchPoint)
        updateDrawLayer()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let newRecord = flattenToImage()
        recordMakedHandler?(newRecord)
        pathPositions.removeAll()
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

        prevFrameRecordView.alpha = 0.5

        backgroundImageView.contentMode = .scaleAspectFill

        drawLayer.contentsScale = drawView.layer.contentsScale
        drawView.layer.addSublayer(drawLayer)
        updateDrawLayerStyle()

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
        NSLayoutConstraint.activate([
            drawView.topAnchor.constraint(equalTo: topAnchor),
            drawView.leftAnchor.constraint(equalTo: leftAnchor),
            drawView.rightAnchor.constraint(equalTo: rightAnchor),
            drawView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // MARK: - Draw

    private func makeLineDrawPath() -> UIBezierPath {
        let linePath = UIBezierPath()
        let smoothPoints = pathPositions.smooth

        if let firstPoint = smoothPoints.first {
            linePath.move(to: firstPoint)

            for point in smoothPoints.dropFirst() {
                linePath.addLine(to: point)
            }
        }

        return linePath
    }

    private func updateDrawLayerStyle() {
        switch instrument {
        case .pencil:
            drawLayer.shadowColor = nil
            drawLayer.shadowRadius = 0
            drawLayer.shadowOpacity = 0.0
            drawLayer.lineWidth = width
            drawLayer.lineCap = .square
            drawLayer.strokeColor = color.cgColor
        case .brush:
            drawLayer.shadowColor = color.cgColor
            drawLayer.shadowRadius = width * 0.15
            drawLayer.shadowOpacity = 1.0
            drawLayer.shadowOffset = .zero
            drawLayer.lineWidth = 0.0
            drawLayer.lineCap = .round
            drawLayer.strokeColor = color.cgColor
        case .erase:
            // erase рисуем сразу в context, так-как нужен blendmode который на Layer не получить.
            break
        }
        drawLayer.opacity = 1.0
        drawLayer.fillColor = UIColor.clear.cgColor
    }

    private func updateDrawLayer() {
        switch instrument {
        case .pencil:
            let linePath = makeLineDrawPath()
            drawLayer.shadowPath = nil
            drawLayer.path = linePath.cgPath
        case .brush:
            let linePath = makeLineDrawPath()
            drawLayer.shadowPath = linePath.cgPath.copy(strokingWithWidth: width, lineCap: .round, lineJoin: .round, miterLimit: 0)
            drawLayer.path = linePath.cgPath
        case .erase:
            currentRecordView.image = makeErasedImage()
        }
    }

    private func flattenToImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            currentRecordView.draw(bounds)
            drawView.drawHierarchy(in: bounds, afterScreenUpdates: false)
        }
    }

    private func emptyImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { _ in }
    }

    private func makeErasedImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            currentRecordView.image = currentRecord
            currentRecordView.draw(bounds)
            rendererContext.cgContext.setBlendMode(.clear)
            rendererContext.cgContext.setLineCap(.butt)
            rendererContext.cgContext.setAlpha(1.0)
            rendererContext.cgContext.setLineWidth(width)

            let smoothPoints = pathPositions.smooth
            if let firstPoint = smoothPoints.first {
                rendererContext.cgContext.move(to: firstPoint)
                for point in smoothPoints.dropFirst() {
                    rendererContext.cgContext.addLine(to: point)
                }
            }
            rendererContext.cgContext.strokePath()
        }
    }
}

extension Array where Element == CGPoint {
    var smooth: [CGPoint] {
        if count < 4 {
            return self
        }

        let granularity = 8
        let controlPoints = [self[0]] + self + [self[count - 1]]
        var result = [controlPoints[0]]

        for i in 1..<(controlPoints.count - 2) {
            let p0 = controlPoints[i - 1]
            let p1 = controlPoints[i]
            let p2 = controlPoints[i + 1]
            let p3 = controlPoints[i + 2]

            for g in 1..<granularity {
                let s1 = Double(g) * (1.0 / Double(granularity))
                let s2 = s1 * s1
                let s3 = s2 * s1

                result.append(CGPoint(
                    x: 0.5 * (2*p1.x+(p2.x - p0.x)*s1 + (2*p0.x-5*p1.x+4*p2.x-p3.x)*s2 + (3*p1.x-p0.x-3*p2.x+p3.x)*s3),
                    y: 0.5 * (2*p1.y+(p2.y - p0.y)*s1 + (2*p0.y-5*p1.y+4*p2.y-p3.y)*s2 + (3*p1.y-p0.y-3*p2.y+p3.y)*s3)
                ))
            }

            result.append(p2)
        }

        result.append(controlPoints[controlPoints.count - 1])

        return result
    }
}
