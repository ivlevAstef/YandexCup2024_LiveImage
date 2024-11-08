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
    case removeAllFrames
    case addFrame
    case dublicateFrame
    case generateFrames
    case toggleFrames

    case pause
    case play
}
