//
//  Canvas.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 29.10.2024.
//

import UIKit

private enum Consts {
    /// Максимальная глубина хранения истории изменений изображений.
    static let maxRecordCapacity = 10
}

struct Canvas {
    typealias Record = UIImage

    final class Frame {
        var currentRecord: Record? { records.indices.contains(currentRecordIndex) ? records[currentRecordIndex] : nil }
        var canUndo: Bool { currentRecordIndex >= 0 }
        var canRedo: Bool { currentRecordIndex < records.count - 1 }

        private var records: [Record] = []
        private var currentRecordIndex: Int = -1

        func addRecord(_ record: Record) {
            // Если мы делали undo, а потом добавили новый фрейм, то все redo шаги мы трём.
            records = Array(records.prefix(currentRecordIndex + 1))
            records.append(record)
            records = Array(records.suffix(Consts.maxRecordCapacity))
            currentRecordIndex = records.count - 1
        }

        func undo() {
            if canUndo {
                currentRecordIndex -= 1
            }
        }

        func redo() {
            if canRedo {
                currentRecordIndex += 1
            }
        }

        init() {}
    }

    var currentFrame: Frame {
        return frames[currentFrameIndex]
    }

    private var frames: [Frame] = [Frame()]
    private var currentFrameIndex: Int = 0
}
