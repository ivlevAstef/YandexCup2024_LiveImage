//
//  EmptyPainter.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 02.11.2024.
//

import UIKit

struct EmptyPainter: ObjectPainter {
    let instrument: DrawInstrument = .erase
    let color: UIColor = .clear
    let lineWidth: CGFloat = 0.0
    let position: CGPoint = .zero
    let rotate: CGFloat = 0.0
    let scale: CGPoint = CGPoint(x: 1.0, y: 1.0)

    func makeImage(on canvasSize: CanvasSize, from image: UIImage?) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = canvasSize.scale
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: canvasSize.size, format: format)

        return renderer.image { _ in }
    }
}
