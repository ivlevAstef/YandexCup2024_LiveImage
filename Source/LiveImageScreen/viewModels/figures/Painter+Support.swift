//
//  Figure+Support.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 02.11.2024.
//

import Foundation

extension Array where Element == CGPoint {
    var smooth: [CGPoint] {
        if count < 4 {
            return self
        }

        let granularity = 8
        let controlPoints = [self[0]] + self + [self[count - 1]]
        var result = [controlPoints[0]]

        for i in 1..<(controlPoints.count - 2) {
            let p0 = controlPoints[i - 1]
            let p1 = controlPoints[i]
            let p2 = controlPoints[i + 1]
            let p3 = controlPoints[i + 2]

            for g in 1..<granularity {
                let s1 = Double(g) * (1.0 / Double(granularity))
                let s2 = s1 * s1
                let s3 = s2 * s1

                result.append(CGPoint(
                    x: 0.5 * (2*p1.x+(p2.x - p0.x)*s1 + (2*p0.x-5*p1.x+4*p2.x-p3.x)*s2 + (3*p1.x-p0.x-3*p2.x+p3.x)*s3),
                    y: 0.5 * (2*p1.y+(p2.y - p0.y)*s1 + (2*p0.y-5*p1.y+4*p2.y-p3.y)*s2 + (3*p1.y-p0.y-3*p2.y+p3.y)*s3)
                ))
            }

            result.append(p2)
        }

        result.append(controlPoints[controlPoints.count - 1])

        return result
    }
}
