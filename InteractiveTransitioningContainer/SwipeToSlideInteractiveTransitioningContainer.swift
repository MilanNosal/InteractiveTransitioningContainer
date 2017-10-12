//
//  SwipeToSlideInteractiveTransitioningContainer.swift
//  InteractiveTransitioningContainer
//
//  Created by Milan Nosáľ on 02/02/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import UIKit

public protocol SwipeToSlideInteractiveTransitioningContainerDelegate: class {
    
    func swipeToSlideInteractiveTransitioningContainer(
        _ swipeToSlideInteractiveTransitioningContainer: SwipeToSlideInteractiveTransitioningContainer,
        didFinishTransitionToIndex selectedIndex: Int,
        wasCancelled: Bool)
    
    
    func swipeToSlideInteractiveTransitioningContainer(
        _ swipeToSlideInteractiveTransitioningContainer: SwipeToSlideInteractiveTransitioningContainer,
        willTransitionFromIndex fromIndex: Int,
        to toIndex: Int,
        coordinatedBy transitionCoordinator: UIViewControllerTransitionCoordinator)
    
}

open class SwipeToSlideInteractiveTransitioningContainer: InteractiveTransitioningContainer, InteractiveTransitioningContainerDelegate {
    
    // MARK: Delegate fields
    fileprivate var animator: UIViewControllerAnimatedTransitioning!
    
    fileprivate var interactionController: SwipeToSlidePanGestureInteractiveTransition!
    
    public var interactiveTransitionGestureRecognizer: UIGestureRecognizer? {
        get {
            return self.interactionController?.gestureRecognizer
        }
    }
    
    // Specific delegate for this container
    public weak var delegate: SwipeToSlideInteractiveTransitioningContainerDelegate?
    
    // MARK: Instance fields
    let viewControllers: [UIViewController]
    
    public init(with viewControllers: [UIViewController]) {
        guard viewControllers.count > 0 else {
            fatalError("SwipeToSlideInteractiveTransitioningContainerDelegate has to be initiated with at least one viewController.")
        }
        self.viewControllers = viewControllers
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func loadView() {
        super.loadView()
        animator = animatorFactory()
        interactionController = interactionControllerFactory(in: self.containerView)
        containerDelegate = self
    }
    
    open func animatorFactory() -> UIViewControllerAnimatedTransitioning {
        return SwipeToSlideTransitionAnimation()
    }
    
    func interactionControllerFactory(in view: UIView) -> SwipeToSlidePanGestureInteractiveTransition {
        return SwipeToSlidePanGestureInteractiveTransition(in: view) {
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
    
    // MARK: InteractiveTransitioningContainerDelegate
    
    public func initialViewController(_ interactiveTransitioningContainer: InteractiveTransitioningContainer) -> UIViewController {
        return viewControllers.first!
    }
    
    public func interactiveTransitioningContainer(
        _ interactiveTransitioningContainer: InteractiveTransitioningContainer,
        animationControllerForTransitionFrom fromViewController: UIViewController,
        to toViewController: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return animator
    }
    
    public func interactiveTransitioningContainer(
        _ interactiveTransitioningContainer: InteractiveTransitioningContainer,
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
        _ interactiveTransitioningContainer: InteractiveTransitioningContainer,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        self.interactionController.animator = animationController
        return self.interactionController
    }
    
    public func interactiveTransitioningContainer(
        _ interactiveTransitioningContainer: InteractiveTransitioningContainer,
        willTransitionFrom fromViewController: UIViewController,
        to toViewController: UIViewController,
        coordinatedBy transitionCoordinator: UIViewControllerTransitionCoordinator) {
        
        let fromIndex = viewControllers.index(of: fromViewController)!
        let toIndex = viewControllers.index(of: toViewController)!
        delegate?.swipeToSlideInteractiveTransitioningContainer(self, willTransitionFromIndex: fromIndex, to: toIndex, coordinatedBy: transitionCoordinator)
    }
    
    public func interactiveTransitioningContainer(
        _ interactiveTransitioningContainer: InteractiveTransitioningContainer,
        transitionFinishedTo viewController: UIViewController,
        wasCancelled: Bool) {
        
        let selectedIndex = viewControllers.index(of: viewController)!
        delegate?.swipeToSlideInteractiveTransitioningContainer(self, didFinishTransitionToIndex: selectedIndex, wasCancelled: wasCancelled)
    }
    
    public func interactiveTransitioningContainer(
        _ interactiveTransitioningContainer: InteractiveTransitioningContainer,
        layoutIfNotAlready viewController: UIViewController, inContainerView containerView: UIView) {
        viewController.view.frame = containerView.bounds
    }
    
    public func interactiveTransitioningContainer(
        _ interactiveTransitioningContainer: InteractiveTransitioningContainer,
        releaseLayoutOf viewController: UIViewController, inContainerView containerView: UIView) {
        
    }
}


