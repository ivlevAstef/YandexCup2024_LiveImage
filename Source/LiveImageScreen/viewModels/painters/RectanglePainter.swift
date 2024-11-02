//
//  RectanglePainter.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 02.11.2024.
//

import UIKit

struct RectanglePainter: EditableFigurePainter {
    let instrument: DrawInstrument = .rectangle
    var color: UIColor = .black
    var fillColor: UIColor = .clear
    var lineWidth: CGFloat = 5.0
    var position: CGPoint = .zero
    var rotate: CGFloat = 0.0
    var scale: CGPoint = CGPoint(x: 1.0, y: 1.0)

    private let cornerRadius: CGFloat

    private var firstPoint: CGPoint?
    private var secondPoint: CGPoint?

    init(cornerRadius: CGFloat = 0.0) {
        self.cornerRadius = cornerRadius
    }

    mutating func clean() {
        firstPoint = nil
        secondPoint = nil
    }

    mutating func movePoint(_ point: CGPoint) {
        firstPoint = firstPoint ?? point
        secondPoint = point
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
        fillLayer(on: canvasSize, layer: drawLayer)
        return drawLayer
    }

    private func makeRectangleDrawPath() -> UIBezierPath {
        guard let firstPoint = firstPoint, let secondPoint = secondPoint else {
            return UIBezierPath()
        }
    
        let minX = min(firstPoint.x, secondPoint.x)
        let minY = min(firstPoint.y, secondPoint.y)
        let maxX = max(firstPoint.x, secondPoint.x)
        let maxY = max(firstPoint.y, secondPoint.y)

        let rect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        if cornerRadius > 0.0 {
            return UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        }
        return UIBezierPath(rect: rect)
    }
}


extension RectanglePainter: OptimizeLayoutObjectPainter {
    func fillLayer(on canvasSize: CanvasSize, layer drawLayer: CAShapeLayer) {
        drawLayer.lineWidth = lineWidth
        drawLayer.lineCap = .square
        drawLayer.strokeColor = color.cgColor
        drawLayer.opacity = 1.0
        drawLayer.fillColor = fillColor.cgColor

        drawLayer.path = makeRectangleDrawPath().cgPath

        drawLayer.contentsScale = canvasSize.scale
        drawLayer.frame = CGRect(origin: .zero, size: canvasSize.size)
    }
}
