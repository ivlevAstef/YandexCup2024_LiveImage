//
//  PencilPainter.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 02.11.2024.
//

import UIKit

struct PencilPainter: EditableObjectPainter {
    let instrument: DrawInstrument = .pencil
    var color: UIColor = .black
    var lineWidth: CGFloat = 5.0
    var position: CGPoint = .zero
    var rotate: CGFloat = 0.0
    var scale: CGPoint = CGPoint(x: 1.0, y: 1.0)

    private var points: [CGPoint] = []

    mutating func clean() {
        points.removeAll()
    }

    mutating func movePoint(_ point: CGPoint) {
        points.append(point)
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
            makeLayer(on: canvasSize).render(in: rendererContext.cgContext)
        }
    }

    private func makeLayer(on canvasSize: CanvasSize) -> CAShapeLayer {
        let drawLayer = CAShapeLayer()
        drawLayer.lineWidth = lineWidth
        drawLayer.lineCap = .square
        drawLayer.strokeColor = color.cgColor
        drawLayer.opacity = 1.0
        drawLayer.fillColor = UIColor.clear.cgColor

        drawLayer.path = makeLinePath().cgPath

        drawLayer.contentsScale = canvasSize.scale
        drawLayer.frame = CGRect(origin: .zero, size: canvasSize.size)

        return drawLayer
    }

    private func makeLinePath() -> UIBezierPath {
        let linePath = UIBezierPath()
        let smoothPoints = points.smooth

        if let firstPoint = smoothPoints.first {
            linePath.move(to: firstPoint)

            for point in smoothPoints.dropFirst() {
                linePath.addLine(to: point)
            }
        }

        return linePath
    }
}
