//
//  LiveImageGenerator.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 30.10.2024.
//

import UIKit

protocol LiveImageGeneratorViewProtocol: AnyObject {
    func showWriteHowManyFramesGenerate(success: @escaping (Int) -> Void)

    func showProgress(text: String)
    func endProgress()
}

final class LiveImageGeneratorPresenter {
    private let view: LiveImageGeneratorViewProtocol

    init(view: LiveImageGeneratorViewProtocol) {
        self.view = view
    }

    func generate(canvasSize: CanvasSize, success successHandler: @escaping ([Canvas.Record]) -> Void) {
        view.showWriteHowManyFramesGenerate { [weak self, weak view] framesCount in
            view?.showProgress(text: "Generating...")
            DispatchQueue.global().async {
                guard let self else {
                    return
                }

                let records = self.generate(canvasSize: canvasSize, framesCount: framesCount)
                DispatchQueue.main.async {
                    view?.endProgress()
                    successHandler(records)
                }
            }
        }
    }

    private func generate(canvasSize: CanvasSize, framesCount: Int) -> [Canvas.Record] {
        return generateUseMoveFigure(canvasSize: canvasSize, framesCount: framesCount)
    }

    /// генерирует указанное количество картинок, используя перемещение случайной фигуры.
    /// Не буду спорить, этот код можно написать гораздо красивее.
    private func generateUseMoveFigure(canvasSize: CanvasSize, framesCount: Int) -> [Canvas.Record] {
        var result: [Canvas.Record] = []

        var figurePainter: EditableFigurePainter
        switch Int.random(in: 0...2) {
        case 0: figurePainter = RectanglePainter(cornerRadius: CGFloat(Int.random(in: 2..<20)))
        case 1: figurePainter = CirclePainter()
        case 2: figurePainter = TrianglePainter()
        default: figurePainter = CirclePainter()
        }

        figurePainter.movePoint(.zero)
        figurePainter.movePoint(CGPoint(x: CGFloat(Int.random(in: 50..<80)), y: CGFloat(Int.random(in: 50..<80))))
        figurePainter.color = UIColor.random()
        figurePainter.fillColor = UIColor.random()
        figurePainter.lineWidth = CGFloat(Int.random(in: 2..<5))

        let xRandInterval = 50..<max(51, (canvasSize.width - 50.0))
        let yRandInterval = 50..<max(51, (canvasSize.height - 50.0))

        var startPosition = CGPoint(x: CGFloat.random(in: xRandInterval), y: CGFloat.random(in: yRandInterval))
        var endPosition = CGPoint(x: CGFloat.random(in: xRandInterval), y: CGFloat.random(in: yRandInterval))
        var startAngle = CGFloat.random(in: 0..<CGFloat.pi)
        var endAngle = CGFloat.random(in: 0..<2*CGFloat.pi)
        var startScale = CGPoint(x: 1.0, y: 1.0)
        var endScale = CGPoint(x: CGFloat.random(in: 0.5..<2.0), y: CGFloat.random(in:0.5..<2.0))

        // Если задали очень много кадров, то делаем анимацию из просто движение по прямой,
        // но каждые следующие step кадров меняется направление угол поворота и scale, тем самым анимация выглядит плавной, и меняющейся даже на больших интервалах.
        let step = 50
        var index = 0
        while index < framesCount {
            let endIndexInSeries = min(framesCount, index + step)
            let framesInSeries = endIndexInSeries - index
            index = endIndexInSeries

            let vector = CGPoint(x: endPosition.x - startPosition.x, y: endPosition.y - startPosition.y)
            for i in 0..<framesInSeries {
                let progress = CGFloat(i) / CGFloat(framesInSeries)
                let position = CGPoint(x: startPosition.x + progress * vector.x,
                                       y: startPosition.y + progress * vector.y)
                figurePainter.position = position
                figurePainter.rotate = startAngle + (endAngle - startAngle) * progress
                figurePainter.scale = CGPoint(x: startScale.x + (endScale.x - startScale.x) * progress,
                                              y: startScale.y + (endScale.y - startScale.y) * progress)
                result.append(Canvas.Record(painter: figurePainter))
            }

            startPosition = endPosition
            startAngle = endAngle
            startScale = endScale

            endPosition = CGPoint(x: CGFloat.random(in: xRandInterval), y: CGFloat.random(in: yRandInterval))
            endAngle = CGFloat.random(in: 0..<2*CGFloat.pi)
            endScale = CGPoint(x: CGFloat.random(in: 0.5..<2.0), y: CGFloat.random(in:0.5..<2.0))
        }

        return result
    }
}
