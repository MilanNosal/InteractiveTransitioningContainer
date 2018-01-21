//
//  SwipeToSlidePanGestureInteractiveTransition.swift
//  InteractiveTransitioningContainer
//
//  Created by Milan Nosáľ on 22/01/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import Foundation

public class SwipeToSlidePanGestureInteractiveTransition: InteractiveTransitionContainerAnimatorBasedPercentDrivenInteractiveTransition {
    
    private let progressNeeded: CGFloat
    
    private let velocityNeeded: CGFloat
    
    private var lastVelocity = CGPoint.zero
    
    public let gestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer()
    
    private var leftToRightTransition = false
    
    private var shouldCompleteTransition = false
    
    // This block gets run when the gesture recognizer start recognizing a pan. Inside, the start of a transition can be triggered.
    private let gestureRecognizedBlock: ((_ recognizer: UIPanGestureRecognizer) -> Void)
    
    public init(in view: UIView, progressThreshold: CGFloat = 0.35, velocityOverrideThreshold: CGFloat = 550, recognizedBlock: @escaping ((_ recognizer: UIPanGestureRecognizer) -> Void)) {
        
        self.progressNeeded = progressThreshold
        self.velocityNeeded = velocityOverrideThreshold
        self.gestureRecognizedBlock = recognizedBlock
        
        super.init()
        
        self.gestureRecognizer.addTarget(self, action: #selector(SwipeToSlidePanGestureInteractiveTransition.pan(recognizer:)))
        view.addGestureRecognizer(self.gestureRecognizer)
        
    }
    
    public override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        
        super.startInteractiveTransition(transitionContext)
        self.leftToRightTransition = gestureRecognizer.velocity(in: gestureRecognizer.view).x > 0
        
    }
    
    @objc private func pan(recognizer: UIPanGestureRecognizer) {
        
        switch recognizer.state {
            
        case .began:
            
            gestureRecognizedBlock(recognizer)
            
        case .changed:
            
            // comming back to initial position in screen can cancel current animation
            // and we need ignore those changes
            guard state != .isInTearDown else {
                return
            }
            
            // Now if it was cancelled and torn down, but panning continues, we restart it
            guard state == .isInteracting else {
                
                gestureRecognizedBlock(recognizer)
                return
            }
            
            guard transitionContext != nil else {
                // transition context has to exist for us to perform transition
                fatalError()
            }
            
            let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
            
            lastVelocity = gestureRecognizer.velocity(in: gestureRecognizer.view)
            
            if (leftToRightTransition && lastVelocity.x < 0) || (!leftToRightTransition && lastVelocity.x > 0) {
                lastVelocity = CGPoint.zero
            }
            
            // This code checks if we came back to starting point, and if yes,
            // we cancel the current transition
            if (leftToRightTransition && translation.x < 0) || (!leftToRightTransition && translation.x > 0) {
                
                self.shouldCompleteTransition = false
                self.updateInteractiveTransition(percentComplete: 0)
                self.cancelInteractiveTransition()
                return
            }
            
            let progress = fabs (translation.x / recognizer.view!.bounds.width)
            
            // Decision if we came far enough to complete the transition automatically even
            // if we finish pan gesture
            self.shouldCompleteTransition = progress > progressNeeded || fabs(lastVelocity.x) > velocityNeeded
            
            self.updateInteractiveTransition(percentComplete: progress)
            
        default:
            
            guard transitionContext != nil, state != .isInTearDown else {
                return
            }
            
            if shouldCompleteTransition {
                self.finishInteractiveTransition()
            } else {
                self.cancelInteractiveTransition()
            }
            shouldCompleteTransition = false
        }
    }
}
