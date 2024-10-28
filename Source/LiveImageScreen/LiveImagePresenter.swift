//
//  LiveImagePresenter.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 28.10.2024.
//

import Foundation

typealias LiveImageActionSelectHandler = (_ action: LiveImageAction) -> Void

protocol LiveImageViewProtocol: AnyObject {
    var actionSelectHandler: LiveImageActionSelectHandler? { get set }
    var availableActions: Set<LiveImageAction> { get set }

}

final class LiveImagePresenter {
    private let view: LiveImageViewProtocol

    init(view: LiveImageViewProtocol) {
        self.view = view

        view.actionSelectHandler = { action in
            log.info("Tap on action: \(action)")
        }
        view.availableActions = [.removeFrame, .addFrame, .showFrames, .play]
    }
}
