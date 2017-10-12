//
//  InteractiveTransitioningContainerPercentDrivenInteractiveTransition.swift
//  InteractiveTransitioningContainer
//
//  Created by Milan Nosáľ on 22/01/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import UIKit

// Custom percent driven interactive transition object - should be inherited from when used with InteractiveTransitioningContainer
// I've had some problems with the original implementation of Alek Akstrom, so I use this slight modification
// This is NOT the recommended approach, left only for backward compatibility with animation
// controllers that do not provide interruptibleAnimator
// If it is possible, please use InteractiveTransitionContainerAnimatorBasedPercentDrivenInteractiveTransition instead
//
// Credits also to Alek Akstrom
// - http://www.iosnomad.com/blog/2014/5/12/interactive-custom-container-view-controller-transitions
public class InteractiveTransitionContainerLayerBasedPercentDrivenInteractiveTransition: InteractiveTransitionContainerPercentDrivenInteractiveTransition {
    
    open override var percentComplete: CGFloat {
        didSet {
            let offset = TimeInterval(percentComplete * duration)
            self.timeOffset = offset
        }
    }
    
    // MARK: Internal fields
    fileprivate var timeOffset: TimeInterval {
        set {
            transitionContext!.containerView.layer.timeOffset = newValue
        }
        get {
            return transitionContext!.containerView.layer.timeOffset
        }
    }
    
    fileprivate var displayLink: CADisplayLink?

    open override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        guard state == .isInactive else {
            return
        }
        
        super.startInteractiveTransition(transitionContext)
        transitionContext.containerView.layer.speed = 0
        self.animator!.animateTransition(using: transitionContext)
    }
    
    open override func cancelInteractiveTransition() {
        guard state == .isInteracting else {
            return
        }
        
        super.cancelInteractiveTransition()
        self.completeTransition()
    }
    
    open override func finishInteractiveTransition() {
        guard state == .isInteracting else {
            return
        }
        
        super.finishInteractiveTransition()
        self.completeTransition()
    }

    // MARK: Internal methods

    fileprivate func completeTransition() {
        displayLink = CADisplayLink(target: self, selector: #selector(InteractiveTransitionContainerLayerBasedPercentDrivenInteractiveTransition.tickAnimation))
        displayLink!.add(to: RunLoop.main, forMode: .commonModes)
    }
    
    @objc fileprivate func tickAnimation() {
        var timeOffset = self.timeOffset
        let tick = displayLink!.duration * CFTimeInterval(self.completionSpeed)
        timeOffset = timeOffset + (transitionContext!.transitionWasCancelled ? -tick : tick)
        
        if timeOffset < 0 || timeOffset > TimeInterval(self.duration) {
            self.transitionFinished()
        } else {
            self.timeOffset = timeOffset
        }
    }
    
    fileprivate func transitionFinished() {
        displayLink!.invalidate()
        
        let layer = transitionContext!.containerView.layer
        layer.speed = 1
        
        if transitionContext!.transitionWasCancelled {
            // TODO: Test for glitch
        } else {
            layer.timeOffset = 0
            layer.beginTime = 0
        }
        
        super.interactiveTransitionCompleted()
    }
}
