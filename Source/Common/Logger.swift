//
//  Logger.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 28.10.2024.
//

import Foundation

/// Ну не могу я жить без логгера. Конечно с радостью бы свой затащил (https://github.com/ivlevAstef/FastLogger), но побоялся.
final class Logger {

    func fatal(_ msg: String, path: StaticString = #file, line: UInt = #line) -> Never {
        let msg = format(msg, level: "🛑", path: path, line: line)
        print(msg)
        fatalError(msg, file: path, line: line)
    }

    func assert(_ msg: String, path: StaticString = #file, line: UInt = #line) {
        let msg = format(msg, level: "⁉️", path: path, line: line)
        assertionFailure(msg)
    }

    func error(_ msg: String, path: StaticString = #file, line: UInt = #line) {
        let msg = format(msg, level: "❗️", path: path, line: line)
        print(msg)
    }

    func warning(_ msg: String, path: StaticString = #file, line: UInt = #line) {
        let msg = format(msg, level: "⚠️", path: path, line: line)
        print(msg)
    }

    func info(_ msg: String, path: StaticString = #file, line: UInt = #line) {
        let msg = format(msg, level: "🔹", path: path, line: line)
        print(msg)
    }

    func debug(_ msg: String, path: StaticString = #file, line: UInt = #line) {
        let msg = format(msg, level: "▶️", path: path, line: line)
        print(msg)
    }

    func trace(_ msg: String, path: StaticString = #file, line: UInt = #line) {
        let msg = format(msg, level: "🗯", path: path, line: line)
        print(msg)
    }

    private func format(_ msg: String, level: StaticString, path: StaticString = #file, line: UInt = #line) -> String {
        let file = ("\(path)" as NSString).lastPathComponent
        return "[\(level)] \(file):\(line): \(msg)"
    }
}
