//
//  SwipeToSlideAutolayoutInteractiveTransitioningContainer.swift
//  InteractiveTransitioningContainer
//
//  Created by Milan Nosáľ on 06/02/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//


import UIKit

public class SwipeToSlideAutolayoutInteractiveTransitioningContainer: SwipeToSlideInteractiveTransitioningContainer {
    
    var layoutConstraintsForVCs: [UIViewController:[NSLayoutConstraint]] = [:]
    
}

extension SwipeToSlideAutolayoutInteractiveTransitioningContainer {
    
    override func animatorFactory() -> UIViewControllerAnimatedTransitioning {
        
        return SwipeToSlideAutolayoutTransitionAnimation()
        
    }
    
    override func interactionControllerFactory(in view: UIView) -> SwipeToSlidePanGestureInteractiveTransition {
        
        return SwipeToSlideAutolayoutPanGestureInteractiveTransition(in: view) {
            [weak weakself = self] (panGestureRecognizer) in
            
            guard let wself = weakself, let selected = wself.selectedViewController else {
                return
            }
            
            let leftToRight = panGestureRecognizer.velocity(in: panGestureRecognizer.view).x > 0
            
            let currentIndex = wself.viewControllers.index(of: selected)!
            if leftToRight && currentIndex > 0 {
                wself.transition(to: wself.viewControllers[currentIndex - 1], interactive: true)
            } else if !leftToRight && currentIndex != wself.viewControllers.count - 1 {
                wself.transition(to: wself.viewControllers[currentIndex + 1], interactive: true)
            }
        }
        
    }
    
}

// MARK: layout of child VCs using autolayout
extension SwipeToSlideAutolayoutInteractiveTransitioningContainer {

    public func interactiveTransitioningContainer(_ interactiveTransitioningContainer: InteractiveTransitioningContainer, releaseLayoutOf viewController: UIViewController, inContainerView containerView: UIView) {
        
        if let constraints = layoutConstraintsForVCs[viewController] {
            
            NSLayoutConstraint.deactivate(constraints)
            viewController.view.removeConstraints(constraints)
            
            layoutConstraintsForVCs[viewController] = nil
            
            viewController.view.translatesAutoresizingMaskIntoConstraints = true
        }
        
    }
    
    public func interactiveTransitioningContainer(_ interactiveTransitioningContainer: InteractiveTransitioningContainer, layoutIfNotAlready viewController: UIViewController, inContainerView containerView: UIView) {
        
        if layoutConstraintsForVCs[viewController] == nil {
            
            viewController.view.translatesAutoresizingMaskIntoConstraints = false
            
            let constraints = viewController.view.pinToSuperViewConstraints(left: 0, right: 0, top: 0, bottom: 0)
            NSLayoutConstraint.activate(constraints)
            layoutConstraintsForVCs[viewController] = constraints
            
            viewController.view.transform = CGAffineTransform.identity
            
            viewController.view.setNeedsLayout()
            viewController.view.layoutIfNeeded()
        }
        
    }
}
