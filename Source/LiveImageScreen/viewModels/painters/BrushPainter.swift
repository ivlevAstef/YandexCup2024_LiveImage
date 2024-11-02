//
//  BrushPainter.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 02.11.2024.
//

import UIKit

struct BrushPainter: EditableObjectPainter {
    let instrument: DrawInstrument = .brush
    var color: UIColor = .black
    var lineWidth: CGFloat = 5.0
    var position: CGPoint = .zero
    var rotate: CGFloat = 0.0
    var scale: CGPoint = CGPoint(x: 1.0, y: 1.0)

    private var line = SmoothLine()

    mutating func clean() {
        line = SmoothLine()
    }

    mutating func movePoint(_ point: CGPoint) {
        line.addPoint(point)
    }

    func makeImage(on canvasSize: CanvasSize, from image: UIImage?) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = canvasSize.scale
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: canvasSize.size, format: format)

        return renderer.image { rendererContext in
            image?.draw(in: CGRect(origin: .zero, size: canvasSize.size))
            rendererContext.cgContext.translateBy(x: position.x, y: position.y)
            rendererContext.cgContext.rotate(by: rotate)
            rendererContext.cgContext.scaleBy(x: scale.x, y: scale.y)
            let drawLayer = makeLayer(on: canvasSize)
            rendererContext.cgContext.setShadow(offset: CGSize(width: 0, height: 0), blur: lineWidth, color: color.cgColor)
            drawLayer.render(in: rendererContext.cgContext)
            rendererContext.cgContext.setShadow(offset: CGSize(width: 0, height: 0), blur: lineWidth, color: color.cgColor)
            drawLayer.render(in: rendererContext.cgContext)
        }
    }

    private func makeLayer(on canvasSize: CanvasSize) -> CAShapeLayer {
        let drawLayer = CAShapeLayer()
        drawLayer.contentsScale = canvasSize.scale
        drawLayer.frame = CGRect(origin: .zero, size: canvasSize.size)
        fillLayer(drawLayer)
        return drawLayer
    }

    private func makeLinePath() -> UIBezierPath {
        let linePath = UIBezierPath()

        let points = line.resultPoints
        if let firstPoint = points.first {
            linePath.move(to: firstPoint)

            for point in points.dropFirst() {
                linePath.addLine(to: point)
            }
        }

        return linePath
    }

    private func fillLayerWithoutShadow(_ drawLayer: CAShapeLayer) {
        drawLayer.shadowColor = nil
        drawLayer.shadowOpacity = 0.0
        drawLayer.lineWidth = lineWidth * 0.8
        drawLayer.lineCap = .round
        drawLayer.strokeColor = color.cgColor
        drawLayer.opacity = 1.0
        drawLayer.fillColor = UIColor.clear.cgColor

        let linePath = makeLinePath()
        drawLayer.path = linePath.cgPath
    }
}


extension BrushPainter: OptimizeLayoutObjectPainter {
    func fillLayer(_ drawLayer: CAShapeLayer) {
        fillLayerWithoutShadow(drawLayer)

        drawLayer.shadowColor = color.cgColor
        drawLayer.shadowOffset = .zero
        drawLayer.shadowRadius = lineWidth * 0.35
        drawLayer.shadowPath = drawLayer.path?.copy(strokingWithWidth: lineWidth * 1.3, lineCap: .round, lineJoin: .round, miterLimit: 0)
        drawLayer.shadowOpacity = 1.0
    }
}
