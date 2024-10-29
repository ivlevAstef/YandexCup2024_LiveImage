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

        func clean() {
            records = []
            currentRecordIndex = -1
        }

        init() {}
    }

    var haveMoreFrames: Bool { frames.count > 1 }

    var prevFrame: Frame? {
        if frames.indices.contains(currentFrameIndex - 1) {
            return frames[currentFrameIndex - 1]
        }
        return nil
    }

    var currentFrame: Frame {
        return frames[currentFrameIndex]
    }

    private var frames: [Frame] = [Frame()]
    private(set) var currentFrameIndex: Int = 0

    mutating func addFrame() {
        frames.append(Frame())
        currentFrameIndex = frames.count - 1
    }

    mutating func removeFrame() {
        // Нельзя удалить единственный фрейм
        if frames.indices.contains(currentFrameIndex) && frames.count > 1 {
            frames.remove(at: currentFrameIndex)
            currentFrameIndex = min(currentFrameIndex, frames.count - 1)
        }
    }

    mutating func removeFrame(in index: Int) {
        // Нельзя удалить единственный фрейм
        if frames.indices.contains(index) && frames.count > 1 {
            frames.remove(at: index)
            if currentFrameIndex >= index {
                currentFrameIndex -= 1
                currentFrameIndex = max(0, currentFrameIndex)
            }
        }
    }

    mutating func dublicateFrame(from index: Int) {
        if frames.indices.contains(index) {
            frames.append(frames[index])
            currentFrameIndex = frames.count - 1
        }
    }

    mutating func changeFrameIndex(_ index: Int) {
        if frames.indices.contains(index) {
            currentFrameIndex = index
        }
    }

    mutating func cleanFrame() {
        currentFrame.clean()
    }
}

extension Canvas {
    func recordsForPlay(emptyRecord: Canvas.Record) -> [Canvas.Record] {
        let frames = frames.suffix(from: currentFrameIndex) + frames.prefix(currentFrameIndex)
        return frames.map { $0.currentRecord ?? emptyRecord }
    }

    func anyRecords(emptyRecord: Canvas.Record) -> [Canvas.Record] {
        return frames.map { $0.currentRecord ?? emptyRecord }
    }
}
