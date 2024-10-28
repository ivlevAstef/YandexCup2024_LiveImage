//
//  ActionPanelView.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 28.10.2024.
//

import Foundation
import UIKit

/// Панель с элементами управления фреймами
/// Решил не делать с помощью navigationBar - в случае если найду время, больше возможностей для кастомизации.
final class ActionPanelView: UIView {
    var tapOnAction: LiveImageActionSelectHandler?

    var availableActions: Set<LiveImageAction> = [] {
        didSet {
            for button in actionButtons {
                button.isEnabled = availableActions.contains(button.action)
            }
        }
    }

    private let leftContentView = UIView(frame: .zero)
    private let undoButton = ActionButton(action: .undo)
    private let redoButton = ActionButton(action: .redo)

    private let centerContentView = UIView(frame: .zero)
    private let removeFrameButton = ActionButton(action: .removeFrame)
    private let addFrameButton = ActionButton(action: .addFrame)
    private let showFramesButton = ActionButton(action: .showFrames)

    private let rightContentView = UIView(frame: .zero)
    private let pauseButton = ActionButton(action: .pause)
    private let playButton = ActionButton(action: .play)

    private var actionButtons: [ActionButton] {
        return [
            undoButton,
            redoButton,
            removeFrameButton,
            addFrameButton,
            showFramesButton,
            pauseButton,
            playButton
        ]
    }

    init() {
        super.init(frame: .zero)

        commonInit()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        addSubview(leftContentView)
        addSubview(centerContentView)
        addSubview(rightContentView)

        leftContentView.addSubview(undoButton)
        leftContentView.addSubview(redoButton)

        centerContentView.addSubview(removeFrameButton)
        centerContentView.addSubview(addFrameButton)
        centerContentView.addSubview(showFramesButton)

        rightContentView.addSubview(pauseButton)
        rightContentView.addSubview(playButton)

        for button in actionButtons {
            button.addAction(UIAction { [weak self, action = button.action] _ in
                self?.tapOnAction?(action)
            }, for: .touchUpInside)
        }

        makeConstraints()
    }

    private func makeConstraints() {
        // Без snapkit не привычно...
        for view in subviews {
            view.translatesAutoresizingMaskIntoConstraints = false
            for subview in view.subviews {
                subview.translatesAutoresizingMaskIntoConstraints = false
            }
        }

        let inset = 16.0
        let space = 8.0
        NSLayoutConstraint.activate([
            leftContentView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: inset),
            leftContentView.topAnchor.constraint(equalTo: topAnchor),
            leftContentView.bottomAnchor.constraint(equalTo: bottomAnchor),

            centerContentView.leftAnchor.constraint(equalTo: leftContentView.rightAnchor, constant: 2 * space),
            centerContentView.topAnchor.constraint(equalTo: topAnchor),
            centerContentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            centerContentView.rightAnchor.constraint(equalTo: rightContentView.leftAnchor, constant: -2 * space),

            rightContentView.topAnchor.constraint(equalTo: topAnchor),
            rightContentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            rightContentView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -inset),

            // Left Content
            undoButton.leftAnchor.constraint(equalTo: leftContentView.leftAnchor),
            undoButton.centerYAnchor.constraint(equalTo: leftContentView.centerYAnchor),

            redoButton.leftAnchor.constraint(equalTo: undoButton.rightAnchor, constant: space),
            redoButton.centerYAnchor.constraint(equalTo: leftContentView.centerYAnchor),
            redoButton.rightAnchor.constraint(equalTo: leftContentView.rightAnchor),

            // Center Content
            removeFrameButton.leftAnchor.constraint(greaterThanOrEqualTo: centerContentView.leftAnchor),
            removeFrameButton.centerYAnchor.constraint(equalTo: centerContentView.centerYAnchor),
            removeFrameButton.rightAnchor.constraint(equalTo: addFrameButton.leftAnchor, constant: -2 * space),

            addFrameButton.centerYAnchor.constraint(equalTo: centerContentView.centerYAnchor),
            addFrameButton.centerXAnchor.constraint(equalTo: centerContentView.centerXAnchor),

            showFramesButton.leftAnchor.constraint(equalTo: addFrameButton.rightAnchor, constant: 2 * space),
            showFramesButton.centerYAnchor.constraint(equalTo: centerContentView.centerYAnchor),
            showFramesButton.rightAnchor.constraint(lessThanOrEqualTo: centerContentView.rightAnchor),

            // Right Content
            pauseButton.leftAnchor.constraint(equalTo: rightContentView.leftAnchor),
            pauseButton.centerYAnchor.constraint(equalTo: rightContentView.centerYAnchor),

            playButton.leftAnchor.constraint(equalTo: pauseButton.rightAnchor, constant: 2 * space),
            playButton.centerYAnchor.constraint(equalTo: rightContentView.centerYAnchor),
            playButton.rightAnchor.constraint(equalTo: rightContentView.rightAnchor)
        ])
    }
}

private final class ActionButton: UIButton {
    let action: LiveImageAction

    init(action: LiveImageAction) {
        self.action = action
        super.init(frame: .zero)

        let image = action.image
        setImage(image?.withTintColor(Colors.textColor), for: .normal)
        setImage(image?.withTintColor(Colors.selectColor), for: .selected)
        setImage(image?.withTintColor(Colors.selectColor), for: .highlighted)
        setImage(image?.withTintColor(Colors.unaccentColor), for: .disabled)

        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 32.0),
            heightAnchor.constraint(equalToConstant: 32.0)
        ])
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LiveImageAction {
    fileprivate var image: UIImage? {
        switch self {
        case .undo: return UIImage(named: "undo")
        case .redo: return UIImage(named: "redo")
        case .removeFrame: return UIImage(named: "remove_frame")
        case .addFrame: return UIImage(named: "plus_frame")
        case .showFrames: return UIImage(named: "frames")
        case .pause: return UIImage(named: "pause")
        case .play: return UIImage(named: "play")
        }
    }
}
