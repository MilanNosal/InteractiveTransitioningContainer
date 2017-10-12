//
//  SwipeToSlideTransitionAnimation.swift
//  InteractiveTransitioningContainer
//
//  Created by Milan Nosáľ on 22/01/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import UIKit

class SwipeToSlideTransitionAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration: TimeInterval
    
    private var interruptibleAnimator: UIViewImplicitlyAnimating?
    
    init(duration: TimeInterval = 0.2) {
        self.duration = duration
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to)
            else {
                return
        }
        
        let animationPositions = createAnimationPositions(using: transitionContext)
        
        self.setupInitialState(
            from: fromView, to: toView,
            in: transitionContext.containerView, positionedBy: animationPositions)
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, options: .curveLinear, animations: {
            self.setupFinalState(
                from: fromView, to: toView,
                in: transitionContext.containerView, positionedBy: animationPositions)
        }, completion: {
            (completed) -> Void in
            self.completeAnimation(
                from: fromView, to: toView,
                positionedBy: animationPositions, using: transitionContext)
        })
    }
    
    /// We rely on the implementation to return the same interruptible animator during the
    /// duration of the transition - please, keep that in mind when implementing your own
    /// animators for usage with our InteractiveTransitioningContainer
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        
        if let interruptibleAnimator = self.interruptibleAnimator {
            return interruptibleAnimator
        } else {
            guard let fromView = transitionContext.view(forKey: .from),
                let toView = transitionContext.view(forKey: .to)
                else {
                    fatalError()
            }
            
            let interruptibleAnimator = createInterruptibleAnimator(
                goingFrom: fromView, to: toView, using: transitionContext)
            self.interruptibleAnimator = interruptibleAnimator
            return interruptibleAnimator
        }
    }
    
    private func createInterruptibleAnimator(goingFrom fromView: UIView,
                                             to toView: UIView,
                                             using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        
        let animationPositions = createAnimationPositions(using: transitionContext)
        
        self.setupInitialState(from: fromView, to: toView, in: transitionContext.containerView, positionedBy: animationPositions)
        
        let duration = self.transitionDuration(using: transitionContext)
        let timingParameters = UICubicTimingParameters(animationCurve: .linear)
        let propertyAnimator = UIViewPropertyAnimator(duration: duration, timingParameters: timingParameters)
        
        propertyAnimator.addAnimations {
            self.setupFinalState(
                from: fromView, to: toView, in: transitionContext.containerView, positionedBy: animationPositions)
        }
        
        propertyAnimator.addCompletion { (animatingPosition) in
            self.completeAnimation(
                from: fromView, to: toView, positionedBy: animationPositions, using: transitionContext)
        }
        
        return propertyAnimator
    }
    
    private func createAnimationPositions(using transitionContext: UIViewControllerContextTransitioning) -> InteractiveTransitioningContainerAnimationPositions {
        
        guard let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to)
            else {
                let containerFrame = transitionContext.containerView.frame
                return InteractiveTransitioningContainerAnimationPositionsImpl(
                    fromInitialFrame: containerFrame, fromFinalFrame: containerFrame,
                    toInitialFrame: containerFrame, toFinalFrame: containerFrame)
        }
        
        let toViewInitialFrame: CGRect = transitionContext.initialFrame(for: toViewController)
        let toViewFinalFrame: CGRect = transitionContext.finalFrame(for: toViewController)
        let fromViewInitialFrame: CGRect = transitionContext.initialFrame(for: fromViewController)
        let fromViewFinalFrame: CGRect = transitionContext.finalFrame(for: fromViewController)
        
        return InteractiveTransitioningContainerAnimationPositionsImpl(
            fromInitialFrame: fromViewInitialFrame, fromFinalFrame: fromViewFinalFrame,
            toInitialFrame: toViewInitialFrame, toFinalFrame: toViewFinalFrame)
    }
    
    private func setupInitialState(from fromView: UIView,
                                   to toView: UIView,
                                   in containerView: UIView,
                                   positionedBy animationPositions: InteractiveTransitioningContainerAnimationPositions) {
        fromView.frame = animationPositions.fromInitialFrame
        toView.frame = animationPositions.toInitialFrame
        
        containerView.addSubview(toView)
    }
    
    private func setupFinalState(from fromView: UIView,
                                 to toView: UIView,
                                 in containerView: UIView,
                                 positionedBy animationPositions: InteractiveTransitioningContainerAnimationPositions) {
        fromView.frame = animationPositions.fromFinalFrame
        toView.frame = animationPositions.toFinalFrame
    }
    
    private func completeAnimation(from fromView: UIView,
                                   to toView: UIView,
                                   positionedBy animationPositions: InteractiveTransitioningContainerAnimationPositions,
                                   using transitionContext: UIViewControllerContextTransitioning) {
        if transitionContext.transitionWasCancelled {
            toView.removeFromSuperview()
            fromView.frame = animationPositions.fromInitialFrame
        } else {
            fromView.removeFromSuperview()
        }
        self.interruptibleAnimator = nil
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }
}
