//
//  SmoothLine.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 02.11.2024.
//

import Foundation

struct SmoothLine {
    private(set) var points: [CGPoint] = []
    private(set) var smoothPoints: [CGPoint] = []

    var resultPoints: [CGPoint] {
        if smoothPoints.isEmpty {
            return points
        }
        return smoothPoints
    }

    private var currentIteration: Int = 0

    mutating func addPoint(_ point: CGPoint) {
        points.append(point)

        if points.count < 3 {
            return
        }

        if currentIteration == 0 {
            smoothPoints = [points[0]]
        } else {
            smoothPoints.removeLast()
        }

        let p0 = points[max(0, currentIteration - 1)]
        let p1 = points[currentIteration]
        let p2 = points[currentIteration + 1]
        let p3 = points[currentIteration + 2]

        let granularity = 8
        for g in 1..<granularity {
            let s1 = Double(g) * (1.0 / Double(granularity))
            let s2 = s1 * s1
            let s3 = s2 * s1

            smoothPoints.append(CGPoint(
                x: 0.5 * (2*p1.x+(p2.x - p0.x)*s1 + (2*p0.x-5*p1.x+4*p2.x-p3.x)*s2 + (3*p1.x-p0.x-3*p2.x+p3.x)*s3),
                y: 0.5 * (2*p1.y+(p2.y - p0.y)*s1 + (2*p0.y-5*p1.y+4*p2.y-p3.y)*s2 + (3*p1.y-p0.y-3*p2.y+p3.y)*s3)
            ))
        }
        smoothPoints.append(p2)
        smoothPoints.append(p3)

        currentIteration += 1
    }
}
