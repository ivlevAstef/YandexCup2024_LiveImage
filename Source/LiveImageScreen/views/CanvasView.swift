//
//  CanvasView.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 29.10.2024.
//

import UIKit

private enum Consts {
    static let backgroundImage = UIImage(named: "background_draw_area")
}

final class CanvasView: UIView, LiveImageCanvasViewProtocol {
    var figureMakedHandler: LiveImageFigureMakedHandler? = nil

    var instrument: DrawInstrument = .pencil {
        didSet { updateDrawLayerStyle() }
    }
    var width: CGFloat = 5.0 {
        didSet { updateDrawLayerStyle() }
    }
    var color: DrawColor = .red {
        didSet { updateDrawLayerStyle() }
    }

    private var pathPositions: [CGPoint] = []

    private let drawLayer = CAShapeLayer()

    private let backgroundImageView = UIImageView(image: Consts.backgroundImage)

    init() {
        super.init(frame: .zero)

        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let newTouchPoint = touches.first?.location(in: self) else {
            return
        }
        pathPositions = [newTouchPoint]
        layer.setNeedsDisplay()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let newTouchPoint = touches.first?.location(in: self) else {
            return
        }

        pathPositions.append(newTouchPoint)
        layer.setNeedsDisplay()
    }

    override func draw(_ layer: CALayer, in ctx: CGContext) {
        let linePath = UIBezierPath()
        let smoothPoints = pathPositions.smooth

        if let firstPoint = smoothPoints.first {
            linePath.move(to: firstPoint)

            for point in smoothPoints.dropFirst() {
                linePath.addLine(to: point)
            }
        }

        drawLayer.shadowPath = linePath.cgPath.copy(strokingWithWidth: width, lineCap: .round, lineJoin: .round, miterLimit: 0)
        drawLayer.path = linePath.cgPath
    }

    private func updateDrawLayerStyle() {
        switch instrument {
        case .pencil:
            drawLayer.shadowColor = nil
            drawLayer.shadowRadius = 0
            drawLayer.shadowOpacity = 0.0
            drawLayer.lineWidth = width
            drawLayer.lineCap = .square
        case .brush:
            drawLayer.shadowColor = color.cgColor
            drawLayer.shadowRadius = width * 0.25
            drawLayer.shadowOpacity = 1.0
            drawLayer.shadowOffset = .zero
            drawLayer.lineWidth = 0.0
            drawLayer.lineCap = .round
        case .erase:
            drawLayer.shadowColor = nil
            drawLayer.shadowRadius = 0
            drawLayer.shadowOpacity = 0.0
            drawLayer.lineWidth = width
            drawLayer.lineCap = .round
        }
        drawLayer.opacity = 1.0
        drawLayer.fillColor = UIColor.clear.cgColor
        drawLayer.strokeColor = color.cgColor

    }

    private func commonInit() {
        backgroundColor = Colors.backgroundColor
        addCSubview(backgroundImageView)

        layer.cornerRadius = 20.0
        layer.cornerCurve = .continuous
        clipsToBounds = true

        backgroundImageView.contentMode = .scaleAspectFill

        drawLayer.contentsScale = layer.contentsScale
        layer.addSublayer(drawLayer)
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
    }
}

extension Array where Element == CGPoint {
    var smooth: [CGPoint] {
        if count < 4 {
            return self
        }

        let granularity = 10
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
