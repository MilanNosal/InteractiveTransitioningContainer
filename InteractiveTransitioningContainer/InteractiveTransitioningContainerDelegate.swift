//
//  InteractiveTransitioningContainerDelegate.swift
//  InteractiveTransitioningContainer
//
//  Created by Milan Nosáľ on 22/01/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import Foundation

protocol InteractiveTransitioningContainerDelegate: class {
    
    /// Returns viewController that manages the initial view of the container
    func initialViewController(
        interactiveTransitioningContainer: InteractiveTransitioningContainer) -> UIViewController
    
    /// Returns animator for the given transition
    func interactiveTransitioningContainer(
        interactiveTransitioningContainer: InteractiveTransitioningContainer,
        animationControllerForTransitionFrom fromViewController: UIViewController,
        to toViewController: UIViewController) -> UIViewControllerAnimatedTransitioning
    
    /// This takes on some responsibility of the transition context, however, without this 
    /// we can hardly keep being fully customizable + working with standard animators
    func interactiveTransitioningContainer(
        interactiveTransitioningContainer: InteractiveTransitioningContainer,
        animationPositionsForTransitionFrom fromViewController: UIViewController,
        to toViewController: UIViewController) -> InteractiveTransitioningContainerAnimationPositions
    
    /// Returns interaction controller for the interactive transition if the container is interactive
    /// nil otherwise
    func interactiveTransitioningContainer(
        interactiveTransitioningContainer: InteractiveTransitioningContainer,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
    
}

extension InteractiveTransitioningContainerDelegate {
    
    /// Allows to set up layout of the child view in container view
    /// Default implementation just sets the child's frame to the container's frame
    /// This allows us to use autolayout for the container if we choose so
    func interactiveTransitioningContainer(
        interactiveTransitioningContainer: InteractiveTransitioningContainer,
        layoutViewController viewController: UIViewController, inContainerView containerView: UIView) {
        
        viewController.view.frame = containerView.frame
        
    }
    
    /// Callback to get informed about finishing the transition
    func interactiveTransitioningContainer(
        interactiveTransitioningContainer: InteractiveTransitioningContainer,
        transitionFinishedTo viewController: UIViewController,
        wasCancelled: Bool) {
        
    }
}

