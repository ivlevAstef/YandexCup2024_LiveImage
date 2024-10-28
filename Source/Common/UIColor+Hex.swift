//
//  UIColor+Hex.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 28.10.2024.
//

import UIKit

extension UIColor {
    var hexColor: UInt64 {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0

        self.getRed(&red, green: &green, blue: &blue, alpha: nil)

        let redInt = UInt64(lroundf(Float(red * 255)))
        let greenInt = UInt64(lroundf(Float(green * 255)))
        let blueInt = UInt64(lroundf(Float(blue * 255)))
        return redInt << 16 + greenInt << 8 + blueInt
    }

    static func color(hex: UInt64, alpha: CGFloat = 1.0) -> UIColor {
        assert(0.0 <= alpha && alpha <= 1.0, "0.0 <= alpha && alpha <= 1.0")
        let alpha = max(0.0, min(alpha, 1.0))

        return UIColor(red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
                       green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
                       blue: CGFloat((hex & 0x0000FF) >> 0) / 255.0,
                       alpha: alpha)
    }

    /// Возвращает яркость от 0 до 1. Где 0 это темный, а 1 это светлый.
    var brightness: CGFloat {
        guard let components = cgColor.components, components.count >= 3 else {
            return 0.0
        }

        return (components[0] * 299.0 + components[1] * 587.0 + components[2] * 114.0) / 1000.0
    }
}

