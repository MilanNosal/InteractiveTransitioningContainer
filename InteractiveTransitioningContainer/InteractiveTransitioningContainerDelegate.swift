//
//  InteractiveTransitioningContainerDelegate.swift
//  InteractiveTransitioningContainer
//
//  Created by Milan Nosáľ on 22/01/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import Foundation

public protocol InteractiveTransitioningContainerDelegate: class {
    
    /// Returns viewController that manages the initial view of the container
    func initialViewController(
        _ interactiveTransitioningContainer: InteractiveTransitioningContainer) -> UIViewController
    
    /// Returns animator for the given transition
    func interactiveTransitioningContainer(
        _ interactiveTransitioningContainer: InteractiveTransitioningContainer,
        animationControllerForTransitionFrom fromViewController: UIViewController,
        to toViewController: UIViewController) -> UIViewControllerAnimatedTransitioning?
    
    /// This takes on some responsibility of the transition context, however, without this 
    /// we can hardly keep being fully customizable + working with standard animators
    func interactiveTransitioningContainer(
        _ interactiveTransitioningContainer: InteractiveTransitioningContainer,
        animationPositionsForTransitionFrom fromViewController: UIViewController,
        to toViewController: UIViewController) -> InteractiveTransitioningContainerAnimationPositions
    
    /// Returns interaction controller for the interactive transition if the container is interactive
    /// nil otherwise
    func interactiveTransitioningContainer(
        _ interactiveTransitioningContainer: InteractiveTransitioningContainer,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
    
    /// Allows to set up layout of the child view in container view (ONLY if it is not already layed out)
    /// This allows us to use autolayout for the container if we choose so
    func interactiveTransitioningContainer(
        _ interactiveTransitioningContainer: InteractiveTransitioningContainer,
        layoutIfNotAlready viewController: UIViewController, inContainerView containerView: UIView)
    
    /// Allows to tear down layout of the child view before removing it from container view
    /// Probably needed only for autolayout
    func interactiveTransitioningContainer(
        _ interactiveTransitioningContainer: InteractiveTransitioningContainer,
        releaseLayoutOf viewController: UIViewController, inContainerView containerView: UIView)
    
    /// Notification callback to get informed about finishing the transition
    func interactiveTransitioningContainer(
        _ interactiveTransitioningContainer: InteractiveTransitioningContainer,
        transitionFinishedTo viewController: UIViewController,
        wasCancelled: Bool)
    
    /// Notification callback to provide the delegate with a transition coordinator object that can be used to add alongside animations for the transition
    func interactiveTransitioningContainer(
        _ interactiveTransitioningContainer: InteractiveTransitioningContainer,
        willTransitionFrom fromViewController: UIViewController,
        to toViewController: UIViewController,
        coordinatedBy transitionCoordinator: UIViewControllerTransitionCoordinator)
}


// MARK: Default implementation for layout
extension InteractiveTransitioningContainerDelegate {
    
    /// Default implementation just sets the child's frame to the container's frame
    public func interactiveTransitioningContainer(
        _ interactiveTransitioningContainer: InteractiveTransitioningContainer,
        layoutIfNotAlready viewController: UIViewController, inContainerView containerView: UIView) {
        viewController.view.frame = containerView.bounds
    }
    
    /// Empty default implementation
    public func interactiveTransitioningContainer(
        _ interactiveTransitioningContainer: InteractiveTransitioningContainer,
        releaseLayoutOf viewController: UIViewController, inContainerView containerView: UIView) {
        
    }
    
    /// Callback to get informed about finishing the transition
    public func interactiveTransitioningContainer(
        _ interactiveTransitioningContainer: InteractiveTransitioningContainer,
        transitionFinishedTo viewController: UIViewController,
        wasCancelled: Bool) {
        
    }
    
    /// Empty default implementation
    public func interactiveTransitioningContainer(
        _ interactiveTransitioningContainer: InteractiveTransitioningContainer,
        willTransitionFrom fromViewController: UIViewController,
        to toViewController: UIViewController,
        coordinatedBy transitionCoordinator: UIViewControllerTransitionCoordinator) {
        
    }
}

