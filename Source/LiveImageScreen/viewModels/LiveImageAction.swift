//
//  LiveImageAction.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 28.10.2024.
//

enum LiveImageAction: Hashable {
    case undo
    case redo

    case removeFrame
    case addFrame
    case toggleFrames

    case pause
    case play
}
