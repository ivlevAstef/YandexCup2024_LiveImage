//
//  Canvas.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 29.10.2024.
//

import UIKit

struct Canvas {
    final class Frame {
        var prevFrame: Frame? = nil
        var nextFrame: Frame? = nil
        var figures: [CanvasFigure] = []
    }

    var frames: [Frame] = []
    var currentFrameIndex: Int = 0
}

enum CanvasFigure {
    case path(CanvasFigurePath)
    case image(UIImage)
}

struct CanvasFigurePath {
    let points: [CGPoint]
    let weight: CGFloat
    let color: DrawColor
}
