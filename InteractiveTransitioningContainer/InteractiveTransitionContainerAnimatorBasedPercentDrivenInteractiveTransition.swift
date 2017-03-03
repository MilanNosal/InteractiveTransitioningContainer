//
//  InteractiveTransitionContainerAnimatorBasedPercentDrivenInteractiveTransition.swift
//  InteractiveTransitioningContainer
//
//  Created by Milan Nosáľ on 23/02/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import UIKit

// Use with animationControllers that provide interruptibleAnimator
// This is the recommended approach
public class InteractiveTransitionContainerAnimatorBasedPercentDrivenInteractiveTransition: InteractiveTransitionContainerPercentDrivenInteractiveTransition {
    
    
    override var percentComplete: CGFloat {
        didSet {
            interruptibleAnimator!.fractionComplete = percentComplete
        }
    }
    
    // MARK: - New implicitlyAnimating controller
    var interruptibleAnimator: UIViewImplicitlyAnimating?

    // MARK: - Transition lifecycle
    
    public override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        
        guard state == .isInactive else {
            return
        }
        
        super.startInteractiveTransition(transitionContext)
        
        self.interruptibleAnimator = self.animator!.interruptibleAnimator!(using: transitionContext)
        
        self.interruptibleAnimator!.startAnimation()
        self.interruptibleAnimator!.pauseAnimation()
        self.interruptibleAnimator!.addCompletion!({ (position) in
            self.interactiveTransitionCompleted()
        })
    }
    
    public override func cancelInteractiveTransition() {
        
        guard state == .isInteracting else {
            return
        }
        
        super.cancelInteractiveTransition()
        
        self.interruptibleAnimator!.isReversed = true
        
        self.interruptibleAnimator!.continueAnimation!(
            withTimingParameters: nil,
            durationFactor: self.interruptibleAnimator!.fractionComplete)
        
    }
    
    public override func finishInteractiveTransition() {
        
        guard state == .isInteracting else {
            return
        }
        
        super.finishInteractiveTransition()
        
        self.interruptibleAnimator!.continueAnimation!(
            withTimingParameters: nil,
            durationFactor: (1 - self.interruptibleAnimator!.fractionComplete))
        
    }

    // MARK: - Internal methods

    override func interactiveTransitionCompleted() {
        
        super.interactiveTransitionCompleted()
        
        self.interruptibleAnimator = nil
        
    }
}
