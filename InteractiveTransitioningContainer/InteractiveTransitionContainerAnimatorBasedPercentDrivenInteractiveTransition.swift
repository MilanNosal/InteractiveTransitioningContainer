//
//  InteractiveTransitionContainerAnimatorBasedPercentDrivenInteractiveTransition.swift
//  InteractiveTransitioningContainer
//
//  Created by Milan Nosáľ on 23/02/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import UIKit

public class InteractiveTransitionContainerAnimatorBasedPercentDrivenInteractiveTransition: InteractiveTransitionContainerPercentDrivenInteractiveTransition {
    
    
    override var percentComplete: CGFloat {
        didSet {
            propertyAnimator!.fractionComplete = percentComplete
        }
    }
    
    // MARK: New implicitlyAnimating controller
    var propertyAnimator: UIViewImplicitlyAnimating?
    
}

// MARK: Transition lifecycle
extension InteractiveTransitionContainerAnimatorBasedPercentDrivenInteractiveTransition {
    
    public override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        
        guard state == .isInactive else {
            return
        }
        
        super.startInteractiveTransition(transitionContext)
        
        self.propertyAnimator = self.animator!.interruptibleAnimator!(using: transitionContext)
        
        self.propertyAnimator!.startAnimation()
        
        self.propertyAnimator!.pauseAnimation()
        
        self.propertyAnimator!.addCompletion!({ (position) in
            
            self.interactiveTransitionCompleted()
            
        })
    }
    
    public override func cancelInteractiveTransition() {
        
        guard state == .isInteracting else {
            return
        }
        
        super.cancelInteractiveTransition()
        
        self.propertyAnimator!.isReversed = true
        
        self.propertyAnimator!.continueAnimation!(
            withTimingParameters: nil,
            durationFactor: self.propertyAnimator!.fractionComplete)
        
    }
    
    public override func finishInteractiveTransition() {
        
        guard state == .isInteracting else {
            return
        }
        
        super.finishInteractiveTransition()
        
        self.propertyAnimator!.continueAnimation!(
            withTimingParameters: nil,
            durationFactor: (1 - self.propertyAnimator!.fractionComplete))
        
    }
}

// MARK: Internal methods
extension InteractiveTransitionContainerAnimatorBasedPercentDrivenInteractiveTransition {
    
    override func interactiveTransitionCompleted() {
        
        super.interactiveTransitionCompleted()
        
        self.propertyAnimator = nil
        
    }
}
