//
//  TrianglePainter.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 02.11.2024.
//

import UIKit

struct TrianglePainter: EditableFigurePainter {
    let instrument: DrawInstrument = .triangle
    var color: UIColor = .black
    var fillColor: UIColor = .clear
    var lineWidth: CGFloat = 5.0
    var position: CGPoint = .zero
    var rotate: CGFloat = 0.0
    var scale: CGPoint = CGPoint(x: 1.0, y: 1.0)

    private var firstPoint: CGPoint?
    private var secondPoint: CGPoint?

    mutating func clean() {
        firstPoint = nil
        secondPoint = nil
        position = .zero
    }

    mutating func movePoint(_ point: CGPoint, initialPoint: CGPoint) {
        let min = CGPoint(x: min(initialPoint.x, point.x), y: min(initialPoint.y, point.y))
        self.position = min
        self.firstPoint = CGPoint(x: initialPoint.x - min.x, y: initialPoint.y - min.y)
        self.secondPoint = CGPoint(x: point.x - min.x, y: point.y - min.y)
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
        drawLayer.contentsScale = canvasSize.scale
        fillLayer(drawLayer)
        return drawLayer
    }

    private func makeTriangleDrawPath() -> UIBezierPath {
        guard let firstPoint = firstPoint, let secondPoint = secondPoint else {
            return UIBezierPath()
        }

        let path = UIBezierPath()
        path.move(to: firstPoint)
        path.addLine(to: CGPoint(x: secondPoint.x, y: firstPoint.y))
        path.addLine(to: CGPoint(x: (firstPoint.x + secondPoint.x) * 0.5, y: secondPoint.y))
        path.close()

        return path
    }

    private func calculateRectangle() -> CGRect {
        if let firstPoint = firstPoint, let secondPoint = secondPoint {
            let min = CGPoint(x: min(firstPoint.x, secondPoint.x), y: min(firstPoint.y, secondPoint.y))
            let max = CGPoint(x: max(firstPoint.x, secondPoint.x), y: max(firstPoint.y, secondPoint.y))

            return CGRect(x: 0, y: 0, width: max.x - min.x, height: max.y - min.y)
        }
        return .zero
    }
}


extension TrianglePainter: OptimizeLayoutObjectPainter {
    func fillLayer(_ drawLayer: CAShapeLayer) {
        drawLayer.shadowColor = nil
        drawLayer.shadowOpacity = 0.0
        drawLayer.lineWidth = lineWidth
        drawLayer.lineCap = .square
        drawLayer.strokeColor = color.cgColor
        drawLayer.opacity = 1.0
        drawLayer.fillColor = fillColor.cgColor

        drawLayer.path = makeTriangleDrawPath().cgPath
    }

    func layerFrame() -> CGRect {
        return calculateRectangle().offsetBy(dx: position.x, dy: position.y)
    }
}
