//
//  Canvas.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 29.10.2024.
//

import UIKit

private enum Consts {
    /// Максимальная глубина хранения истории изменений изображений.
    static let maxRecordCapacity = 16
    /// Максимальная глубина хранения истории изменений изображений, для неактивных кадров.
    static let maxCleanedRecordCapacity = 2
}

struct Canvas {
    typealias Record = UIImage

    final class Frame {
        var currentRecord: Record? { records.indices.contains(currentRecordIndex) ? records[currentRecordIndex] : nil }
        var canUndo: Bool { currentRecordIndex > 0 || (currentStartIndex == 0 && currentRecordIndex == 0) }
        var canRedo: Bool { currentRecordIndex < records.count - 1 }

        private var records: [Record] = []
        private var currentRecordIndex: Int = -1
        private var currentStartIndex: Int = 0

        init() {}

        func addRecord(_ record: Record) {
            // Если мы делали undo, а потом добавили новый фрейм, то все redo шаги мы трём.
            records = Array(records.prefix(currentRecordIndex + 1))
            records.append(record)
            suffix(Consts.maxRecordCapacity)
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
        func cleanHistory() {
            // Затираем историю если было undo
            records = Array(records.prefix(currentRecordIndex + 1))
            // Стираем лишнее - чтобы память не так быстро забивалась
            suffix(Consts.maxCleanedRecordCapacity)
            currentRecordIndex = records.count - 1
        }

        fileprivate func copy() -> Frame {
            let result = Frame()
            result.records = records
            result.currentRecordIndex = currentRecordIndex
            result.currentStartIndex = currentStartIndex
            return result
        }

        private func suffix(_ count: Int) {
            if records.count > count {
                currentStartIndex += records.count - count
                records = Array(records.suffix(count))
            }
        }
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
        cleanHistory()
        frames.append(Frame())
        currentFrameIndex = frames.count - 1
    }

    mutating func addFrames(by records: [Canvas.Record]) {
        cleanHistory()
        let newFrames = records.map { record in
            let frame = Frame()
            frame.addRecord(record)
            return frame
        }
        frames.append(contentsOf: newFrames)
        currentFrameIndex = frames.count - newFrames.count
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
            let frame = frames[index].copy()
            cleanHistory()
            frames.append(frame)
            currentFrameIndex = frames.count - 1
        }
    }

    mutating func changeFrameIndex(_ index: Int) {
        if frames.indices.contains(index) {
            currentFrame.cleanHistory()
            currentFrameIndex = index
        }
    }

    mutating func cleanFrame() {
        currentFrame.clean()
    }

    /// Без этого очень быстро память заполняеться. Конечно в идеале, можно было выгружать на диск, а потом возвращать с диска, но этого не требуется.
    mutating func cleanHistory() {
        for frame in frames {
            frame.cleanHistory()
        }
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
