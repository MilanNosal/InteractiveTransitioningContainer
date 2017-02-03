//
//  SwipeToSlidePanGestureInteractiveTransition.swift
//  InteractiveTransitioningContainer
//
//  Created by Milan Nosáľ on 22/01/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import Foundation

class SwipeToSlidePanGestureInteractiveTransition: InteractiveTransitionContainerPercentDrivenInteractiveTransition {
    
    private let progressNeeded: CGFloat
    
    private let velocityNeeded: CGFloat
    
    private var lastVelocity = CGPoint.zero
    
    let gestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer()
    
    private var leftToRightTransition = false
    
    private var shouldCompleteTransition = false
    
    // This block gets run when the gesture recognizer start recognizing a pan. Inside, the start of a transition can be triggered.
    private let gestureRecognizedBlock: ((_ recognizer: UIPanGestureRecognizer) -> Void)
    
    
    
    var isReadyToStart: Bool = false
    
    
    
    init(in view: UIView, progressThreshold: CGFloat = 0.35, velocityOverrideThreshold: CGFloat = 550, recognizedBlock: @escaping ((_ recognizer: UIPanGestureRecognizer) -> Void)) {
        
        self.progressNeeded = progressThreshold
        self.velocityNeeded = velocityOverrideThreshold
        self.gestureRecognizedBlock = recognizedBlock
        
        super.init()
        
        self.gestureRecognizer.addTarget(self, action: #selector(SwipeToSlidePanGestureInteractiveTransition.pan(recognizer:)))
        view.addGestureRecognizer(self.gestureRecognizer)
        
    }
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        
        guard isReadyToStart else {
            fatalError("Call of startInteractiveTransition in unsupported flow.")
        }
        
        super.startInteractiveTransition(transitionContext)
        self.leftToRightTransition = gestureRecognizer.velocity(in: gestureRecognizer.view).x > 0
        
    }
    
    @objc private func pan(recognizer: UIPanGestureRecognizer) {
        
        switch recognizer.state {
            
        case .began:
            isReadyToStart = true
            gestureRecognizedBlock(recognizer)
            isReadyToStart = false
            
        case .changed:
            
            // comming back to initial position in screen can cancel current animation
            // and we need ignore those changes (context can be lost due to cancelling the 
            // transition)
            guard transitionContext != nil, !isInTearDown else {
                return
            }
            
            // Now if it was cancelled and torn down, but panning continues, we restart it
            if !isInInteraction {
                
                isReadyToStart = true
                gestureRecognizedBlock(recognizer)
                isReadyToStart = false
                return
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
            
            guard transitionContext != nil, !isInTearDown else {
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
