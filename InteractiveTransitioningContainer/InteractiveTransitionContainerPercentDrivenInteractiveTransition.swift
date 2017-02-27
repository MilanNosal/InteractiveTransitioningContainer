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
    public var completionCurve: UIViewAnimationCurve = .linear
    
    // Duration is delegated to the animator
    public var duration: CGFloat {
        return CGFloat(animator!.transitionDuration(using: transitionContext!))
    }
    
    var percentComplete: CGFloat {
        didSet {
            
            // TODO test ci ide
            
            transitionContext!.updateInteractiveTransition(percentComplete)
            
        }
    }
    
    public var completionSpeed: CGFloat = 1
    
    
    // MARK: Context fields
    weak var animator: UIViewControllerAnimatedTransitioning?
    
    weak var transitionContext: UIViewControllerContextTransitioning?
    
    // MARK: Flag reporting the state
    fileprivate(set) var state: InteractiveTransitionControllerState = .isInactive
    
    // MARK: Initializers
    convenience init(with animator: UIViewControllerAnimatedTransitioning) {
        self.init()
        self.animator = animator
    }
    
    override init() {
        percentComplete = 0
        super.init()
    }
}

// MARK: Transition lifecycle
extension InteractiveTransitionContainerPercentDrivenInteractiveTransition {
    
    public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        
        assert(self.animator != nil, "Animator object must be set on interactive transitioning context.")
        
        guard state == .isInactive else {
            return
        }
        
        self.state = .isInteracting
        
        self.transitionContext = transitionContext
        
    }
    
    public func updateInteractiveTransition(percentComplete: CGFloat) {
        
        guard state == .isInteracting else {
            return
        }
        
        let percent = fmin(percentComplete, 1)
        let normalizedPercent = fmax(percent, 0)
        self.percentComplete = normalizedPercent
        
    }
    
    public func cancelInteractiveTransition() {
        
        guard state == .isInteracting else {
            return
        }
        
        self.state = .isInTearDown
        
        transitionContext!.cancelInteractiveTransition()
        
    }
    
    public func finishInteractiveTransition() {
        
        guard state == .isInteracting else {
            return
        }
        
        self.state = .isInTearDown
        
        self.transitionContext!.finishInteractiveTransition()
        
    }
}

// MARK: Internal methods
extension InteractiveTransitionContainerPercentDrivenInteractiveTransition {
    
    func interactiveTransitionCompleted() {
        
        self.state = .isInactive
        
    }
}

