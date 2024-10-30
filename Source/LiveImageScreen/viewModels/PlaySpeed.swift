//
//  PlaySpeed.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 31.10.2024.
//

enum PlaySpeed: CaseIterable {
    /// Четверть 6 кадров
    case quarter
    /// Половинка 12 кадров
    case half
    /// Стандартных 24 кадра
    case normal
    /// Так написано в википедии, что 30 кадров использовалось для широкоформатного видео
    case widescreenVideo
    /// Так написано в википедии, что 48 кадров использовалось для imax HD
    case imaxHD
    /// Так написано в википедии, что 60 кадров используеться в каком-то там американском стандарте
    case americaStandartVideo
    /// Просто чтобы смотреть быстро 120 кадров в секунду.
    case faster
}

extension PlaySpeed {
    var fps: Int {
        switch self {
        case .quarter:
            return 6
        case .half:
            return 12
        case .normal:
            return 24
        case .widescreenVideo:
            return 30
        case .imaxHD:
            return 48
        case .americaStandartVideo:
            return 60
        case .faster:
            return 120
        }
    }

    var name: String {
        switch self {
        case .quarter:
            return "x0.25"
        case .half:
            return "x0.5"
        case .normal:
            return "x1"
        case .widescreenVideo:
            return "widescreen video"
        case .imaxHD:
            return "IMAX HD"
        case .americaStandartVideo:
            return "x2"
        case .faster:
            return "x4"
        }
    }
}
