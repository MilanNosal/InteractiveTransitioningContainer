//
//  SwipeToSlideInteractiveTransitioningContainer.swift
//  InteractiveTransitioningContainer
//
//  Created by Milan Nosáľ on 02/02/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import UIKit

public class SwipeToSlideInteractiveTransitioningContainer: InteractiveTransitioningContainer {
    
    // MARK: Delegate fields
    let animator = SwipeToSlideTransitionAnimation()
    
    fileprivate var interactionController: SwipeToSlidePanGestureInteractiveTransition!
    
    var interactiveTransitionGestureRecognizer: UIGestureRecognizer? {
        get {
            return self.interactionController?.gestureRecognizer
        }
    }
    
    // MARK: Instance fields
    let viewControllers: [UIViewController]
    
    public init(with viewControllers: [UIViewController]) {
        
        guard viewControllers.count > 0 else {
            fatalError("SwipeToSlideInteractiveTransitioningContainerDelegate has to be initiated with at least one viewController.")
        }
        
        self.viewControllers = viewControllers
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension SwipeToSlideInteractiveTransitioningContainer {
    
    override public func loadView() {
        super.loadView()
        
        interactionController = SwipeToSlidePanGestureInteractiveTransition(in: self.containerView) {
            [weak weakself = self] (panGestureRecognizer) in
            
            guard let wself = weakself, let selected = wself.selectedViewController else {
                return
            }
            
            let leftToRight = panGestureRecognizer.velocity(in: panGestureRecognizer.view).x > 0
            
            let currentIndex = wself.viewControllers.index(of: selected)!
            if leftToRight && currentIndex > 0 {
                wself.transit(to: wself.viewControllers[currentIndex - 1])
            } else if !leftToRight && currentIndex != wself.viewControllers.count - 1 {
                wself.transit(to: wself.viewControllers[currentIndex + 1])
            }
        }
        
        delegate = self
    }
    
}

extension SwipeToSlideInteractiveTransitioningContainer: InteractiveTransitioningContainerDelegate {
    
    public func initialViewController(
        interactiveTransitioningContainer: InteractiveTransitioningContainer) -> UIViewController {
        
        return viewControllers.first!
        
    }
    
    public func interactiveTransitioningContainer(
        interactiveTransitioningContainer: InteractiveTransitioningContainer,
        animationControllerForTransitionFrom fromViewController: UIViewController,
        to toViewController: UIViewController) -> UIViewControllerAnimatedTransitioning {
        
        return animator
        
    }
    
    public func interactiveTransitioningContainer(
        interactiveTransitioningContainer: InteractiveTransitioningContainer,
        animationPositionsForTransitionFrom fromViewController: UIViewController,
        to toViewController: UIViewController) -> InteractiveTransitioningContainerAnimationPositions {
        
        let fromViewControllerIndex = self.viewControllers.index(of: fromViewController)!
        let toViewControllerIndex = self.viewControllers.index(of: toViewController)!
        
        let goingRight = fromViewControllerIndex < toViewControllerIndex
        
        let travelDistance = goingRight ? -interactiveTransitioningContainer.containerView.bounds.size.width : interactiveTransitioningContainer.containerView.bounds.size.width
        
        let fromInitialFrame = interactiveTransitioningContainer.containerView.bounds
        let toFinalFrame = interactiveTransitioningContainer.containerView.bounds
        let fromFinalFrame = interactiveTransitioningContainer.containerView.bounds.offsetBy(dx: travelDistance, dy: 0)
        let toInitialFrame = interactiveTransitioningContainer.containerView.bounds.offsetBy(dx: -travelDistance, dy: 0)
        
        return InteractiveTransitioningContainerAnimationPositionsImpl(fromInitialFrame: fromInitialFrame, fromFinalFrame: fromFinalFrame, toInitialFrame: toInitialFrame, toFinalFrame: toFinalFrame)
        
    }
    
    public func interactiveTransitioningContainer(
        interactiveTransitioningContainer: InteractiveTransitioningContainer,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        if interactionController.isReadyToStart == true {
            self.interactionController.animator = animationController
            return self.interactionController
        } else {
            return nil
        }
        
    }
}


