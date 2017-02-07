//
//  SwipeToSlideAutolayoutTransitionAnimation.swift
//  InteractiveTransitioningContainer
//
//  Created by Milan Nosáľ on 06/02/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import UIKit

// I believe it would be simpler to just reuse SwipeToSlideTransitionAnimation implementation,
// but I tried out using transformations to animate
class SwipeToSlideAutolayoutTransitionAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let kDuration: TimeInterval
    
    init(duration: TimeInterval = 0.2) {
        kDuration = duration
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return kDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to),
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to)
            else {
                return
        }
        
        let containerView = transitionContext.containerView
        
        let toViewInitialFrame: CGRect = transitionContext.initialFrame(for: toViewController)
        let toViewFinalFrame: CGRect = transitionContext.finalFrame(for: toViewController)
        let fromViewFinalFrame: CGRect = transitionContext.finalFrame(for: fromViewController)
        let fromViewInitialFrame: CGRect = transitionContext.initialFrame(for: fromViewController)
        
        toView.frame = toViewFinalFrame
        toView.transform = CGAffineTransform(translationX: toViewInitialFrame.origin.x, y: 0)
        containerView.addSubview(toView)
        
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, options: .curveLinear, animations: {
            
            fromView.transform = CGAffineTransform(translationX: fromViewFinalFrame.origin.x, y: 0)
            toView.transform = CGAffineTransform.identity
            
        }, completion: {
            (completed) -> Void in
            
            if transitionContext.transitionWasCancelled {
                
                toView.removeFromSuperview()
                toView.transform = CGAffineTransform.identity
                
                fromView.frame = fromViewInitialFrame
                fromView.transform = CGAffineTransform.identity
                
            } else {
                
                toView.frame = fromViewInitialFrame
                toView.transform = CGAffineTransform.identity
                
                fromView.removeFromSuperview()
                fromView.transform = CGAffineTransform.identity
                
            }
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
        })
    }
}

