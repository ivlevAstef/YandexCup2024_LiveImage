//
//  UIColor+Hex.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 28.10.2024.
//

import UIKit

extension UIColor {
    /// Создает цвет по числу вида: `0x000000`.
    /// - Parameter hex: Число в формате `0x000000` где цифры означают RGB записанный в 16 ричном формате.
    /// - Parameter alpha: Значение альфа канала от 0 до 1. По умолчанию 1 - полностью не прозрачный.
    /// - Returns: Цвет соответствующий входному значения или `nil` если не удалось распарсить.
    public static func color(hex: UInt64, alpha: CGFloat = 1.0) -> UIColor {
        assert(0.0 <= alpha && alpha <= 1.0, "0.0 <= alpha && alpha <= 1.0")
        let alpha = max(0.0, min(alpha, 1.0))

        return UIColor(red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
                       green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
                       blue: CGFloat((hex & 0x0000FF) >> 0) / 255.0,
                       alpha: alpha)
    }
}

