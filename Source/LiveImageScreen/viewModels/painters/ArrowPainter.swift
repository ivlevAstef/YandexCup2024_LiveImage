//
//  ArrowPainter.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 02.11.2024.
//

import UIKit

struct ArrowPainter: EditableObjectPainter {
    let instrument: DrawInstrument = .arrow
    var color: UIColor = .black
    var lineWidth: CGFloat = 5.0
    var position: CGPoint = .zero
    var rotate: CGFloat = 0.0
    var scale: CGPoint = CGPoint(x: 1.0, y: 1.0)

    private var firstPoint: CGPoint?
    private var secondPoint: CGPoint?

    mutating func clean() {
        position = .zero
        firstPoint = nil
        secondPoint = nil
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
        drawLayer.frame = CGRect(origin: .zero, size: canvasSize.size)
        fillLayer(drawLayer)
        return drawLayer
    }

    private func makeArrowDrawPath() -> UIBezierPath {
        guard let start = firstPoint, let end = secondPoint else {
            return UIBezierPath()
        }

        let vector = CGPoint(x: end.x - start.x, y: end.y - start.y)
        let startEndAngle: CGFloat
        if (abs(vector.x) < 1.0e-7) {
            startEndAngle = vector.y < 0 ? -CGFloat.pi / 2.0 : CGFloat.pi / 2.0
        } else {
            startEndAngle = atan(vector.y / vector.x) + (vector.x < 0 ? CGFloat.pi : 0)
        }

        let arrowAngle = CGFloat.pi * 1.0 / 6.0
        let procentLength = (lineWidth / 60.0)
        let arrowLength = procentLength * sqrt(vector.x * vector.x + vector.y * vector.y)
        let arrowLine1 = CGPoint(x: end.x + arrowLength * cos(CGFloat.pi - startEndAngle + arrowAngle),
                                 y: end.y - arrowLength * sin(CGFloat.pi - startEndAngle + arrowAngle))
        let arrowLine2 = CGPoint(x: end.x + arrowLength * cos(CGFloat.pi - startEndAngle - arrowAngle),
                                 y: end.y - arrowLength * sin(CGFloat.pi - startEndAngle - arrowAngle))

        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)

        path.move(to: end)
        path.addLine(to: arrowLine1)

        path.move(to: end)
        path.addLine(to: arrowLine2)

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


extension ArrowPainter: OptimizeLayoutObjectPainter {
    func fillLayer(_ drawLayer: CAShapeLayer) {
        drawLayer.shadowColor = nil
        drawLayer.shadowOpacity = 0.0
        drawLayer.lineWidth = lineWidth
        drawLayer.lineCap = .round
        drawLayer.strokeColor = color.cgColor
        drawLayer.opacity = 1.0
        drawLayer.fillColor = UIColor.clear.cgColor

        drawLayer.path = makeArrowDrawPath().cgPath
    }

    func layerFrame() -> CGRect {
        return calculateRectangle().offsetBy(dx: position.x, dy: position.y)
    }
}
