//
//  Figure.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 02.11.2024.
//

import UIKit

// TODO: в целом Painter-ы можно разделить то на три категории:
// Pencil + Brush, Erase, Figure
// Но copy paste рулит :D

protocol ObjectPainter {
    var instrument: DrawInstrument { get }
    var color: UIColor { get }
    var lineWidth: CGFloat { get }
    var position: CGPoint { get }
    var rotate: CGFloat { get }
    var scale: CGPoint { get }

    func makeImage(on canvasSize: CanvasSize, from image: UIImage?) -> UIImage
}


protocol EditableObjectPainter: ObjectPainter {
    var color: UIColor { get set }
    var lineWidth: CGFloat { get set }
    var position: CGPoint { get set }
    var rotate: CGFloat { get set }
    var scale: CGPoint { get set }

    mutating func clean()
    mutating func movePoint(_ point: CGPoint)
}
