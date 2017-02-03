//
//  SwipeToSlideTransitionAnimation.swift
//  InteractiveTransitioningContainer
//
//  Created by Milan Nosáľ on 22/01/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import UIKit


class SwipeToSlideTransitionAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
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
        
        toView.frame = toViewInitialFrame
        fromView.frame = fromViewInitialFrame
        
        containerView.addSubview(toView)
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, options: .curveLinear, animations: {
            
            fromView.frame = fromViewFinalFrame
            toView.frame = toViewFinalFrame
            
        }, completion: {
            (completed) -> Void in
            
            if transitionContext.transitionWasCancelled {
                
                toView.removeFromSuperview()
                
                fromView.frame = fromViewInitialFrame
                
            } else {
                
                fromView.removeFromSuperview()
                
            }
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
        })
    }
}
