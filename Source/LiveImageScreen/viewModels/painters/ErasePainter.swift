//
//  ErasePainter.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 02.11.2024.
//

import UIKit

struct ErasePainter: EditableObjectPainter {
    let instrument: DrawInstrument = .erase
    var color: UIColor = .clear
    var lineWidth: CGFloat = 5.0
    var position: CGPoint = .zero
    var rotate: CGFloat = 0.0
    var scale: CGPoint = CGPoint(x: 1.0, y: 1.0)

    private var points: [CGPoint] = []

    mutating func clean() {
        points.removeAll()
    }

    mutating func movePoint(_ point: CGPoint, initialPoint: CGPoint) {
        points.append(point)
    }

    func makeImage(on canvasSize: CanvasSize, from image: UIImage?) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = canvasSize.scale
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: canvasSize.size, format: format)

        return renderer.image { rendererContext in
            image?.draw(in: CGRect(origin: .zero, size: canvasSize.size))

            rendererContext.cgContext.setBlendMode(.clear)
            rendererContext.cgContext.setLineCap(.butt)
            rendererContext.cgContext.setAlpha(1.0)
            rendererContext.cgContext.setLineWidth(lineWidth * 2.0)

            if let firstPoint = points.first {
                rendererContext.cgContext.move(to: firstPoint)
                for point in points.dropFirst() {
                    rendererContext.cgContext.addLine(to: point)
                }
            }
            rendererContext.cgContext.strokePath()
        }
    }
}
