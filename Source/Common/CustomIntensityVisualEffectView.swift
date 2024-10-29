//
//  UIBlurEffect+Radius.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 30.10.2024.
//

import UIKit

/// Честно взято от сюда: https://stackoverflow.com/questions/25529500/how-to-set-the-blurradius-of-uiblureffectstyle-light
final class CustomIntensityVisualEffectView: UIVisualEffectView {

    /// Create visual effect view with given effect and its intensity
    ///
    /// - Parameters:
    ///   - effect: visual effect, eg UIBlurEffect(style: .dark)
    ///   - intensity: custom intensity from 0.0 (no effect) to 1.0 (full effect) using linear scale
    init(effect: UIVisualEffect, intensity: CGFloat) {
        super.init(effect: nil)

        let animator = UIViewPropertyAnimator(duration: 1, curve: .linear) {
            self.effect = effect
        }
        self.animator = animator
        animator.fractionComplete = intensity
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: Private
    private var animator: UIViewPropertyAnimator?

}
