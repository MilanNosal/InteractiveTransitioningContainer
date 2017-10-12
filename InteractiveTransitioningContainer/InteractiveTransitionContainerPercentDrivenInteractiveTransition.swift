//
//  InteractiveTransitionContainerPercentDrivenInteractiveTransition.swift
//  InteractiveTransitioningContainer
//
//  Created by Milan Nosáľ on 23/02/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import UIKit

public class InteractiveTransitionContainerPercentDrivenInteractiveTransition: NSObject, UIViewControllerInteractiveTransitioning {
    
    // MARK: UIPercentDrivenInteractiveTransition fields
    open var completionCurve: UIViewAnimationCurve = .linear
    
    // Duration is delegated to the animator
    open var duration: CGFloat {
        return CGFloat(animator!.transitionDuration(using: transitionContext!))
    }
    
    open var percentComplete: CGFloat {
        didSet {
            transitionContext!.updateInteractiveTransition(percentComplete)
        }
    }
    
    open var completionSpeed: CGFloat = 1
    
    
    // MARK: Context fields
    open weak var animator: UIViewControllerAnimatedTransitioning?
    
    open weak var transitionContext: UIViewControllerContextTransitioning?
    
    // MARK: Flag reporting the state
    fileprivate(set) var state: InteractiveTransitionControllerState = .isInactive
    
    // MARK: Initializers
    public convenience init(with animator: UIViewControllerAnimatedTransitioning) {
        self.init()
        self.animator = animator
    }
    
    public override init() {
        percentComplete = 0
        super.init()
    }

    // MARK: Transition lifecycle
    
    open func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        assert(self.animator != nil, "Animator object must be set on interactive transitioning context.")
        
        guard state == .isInactive else {
            return
        }
        
        self.state = .isInteracting
        self.transitionContext = transitionContext
    }
    
    open func updateInteractiveTransition(percentComplete: CGFloat) {
        guard state == .isInteracting else {
            return
        }
        
        let percent = fmin(percentComplete, 1)
        let normalizedPercent = fmax(percent, 0)
        self.percentComplete = normalizedPercent
    }
    
    open func cancelInteractiveTransition() {
        guard state == .isInteracting else {
            return
        }
        
        self.state = .isInTearDown
        transitionContext!.cancelInteractiveTransition()
    }
    
    open func finishInteractiveTransition() {
        guard state == .isInteracting else {
            return
        }
        
        self.state = .isInTearDown
        self.transitionContext!.finishInteractiveTransition()
    }

    // MARK: Internal methods
    
    open func interactiveTransitionCompleted() {
        self.state = .isInactive
    }
}

