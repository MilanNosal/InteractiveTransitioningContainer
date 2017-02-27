//
//  InteractiveTransitioningContainer.swift
//  InteractiveTransitioningContainer
//
//  Created by Milan Nosáľ on 22/01/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import UIKit

/// Skeleton container taking care of transition lifecycle
/// Use the delegate to customize it (see example in SwipeToSlideContainer)
//
// Additional credits to Joachim Bondo
// - https://www.objc.io/issues/12-animations/custom-container-view-controller-transitions/
// and Alek Akstrom
// - http://www.iosnomad.com/blog/2014/5/12/interactive-custom-container-view-controller-transitions
public class InteractiveTransitioningContainer: UIViewController {
    
    /// Delegate is used for managing all the custom behavior - without the delegate the container
    /// itself is responsible for calling the initial transit, plus all transitions will be forced 
    /// to be non-animated (animator has to be fed using the delegate)
    /// Be careful, the reference is weak
    weak var containerDelegate: InteractiveTransitioningContainerDelegate?
    
    fileprivate(set) public var selectedViewController: UIViewController?
    
    fileprivate(set) public var containerView: UIView!
    
    fileprivate weak var transitionCoordinatorField: InteractiveTransitioningContainerTransitionCoordinator?
    
    public func transition(to viewController: UIViewController, animated: Bool = true, interactive: Bool = false) {
        
        self.transition(from: selectedViewController, to: viewController, animated: animated, interactive: interactive)
        
    }
    
}

// MARK: Initialization
extension InteractiveTransitioningContainer {
    
    public override func loadView() {
        
        super.loadView()
        
        self.containerView = self.view
        
        layoutComponents()
        
        setAtributes()
        
        applyConstraints()
        
    }
    
    private func layoutComponents() {
        
    }
    
    private func setAtributes() {
        
        view.backgroundColor = .clear
        view.isOpaque = true
        
    }
    
    fileprivate func applyConstraints() {
        
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if let containerDelegate = containerDelegate {
            transition(to: containerDelegate.initialViewController(self))
        }
        
    }
    
}

// MARK: transitioning
extension InteractiveTransitioningContainer {
    
    fileprivate func transition(
        from fromViewController: UIViewController?,
        to toViewController: UIViewController,
        animated: Bool,
        interactive: Bool) {
        
        
        guard toViewController != fromViewController && self.isViewLoaded else {
            return
        }
        
        // start of transition lifecycle
        fromViewController?.willMove(toParentViewController: nil)
        self.addChildViewController(toViewController)
        
        // If this is the initial presentation, add the new child with no animation
        guard let fromViewController = fromViewController else {
            
            completeSuccessfulTransition(from: nil, to: toViewController)
            
            return
        }
        
        // we create the transition drivers (animator, interactionController, transitionContext)
        let animationController = createAnimationController(forTransitionFrom: fromViewController, to: toViewController)
        
        let interactionController = createInteractionController(for: animationController)
        
        let transitionContext = createTransitionContext(
            forTransitionFrom: fromViewController, to: toViewController,
            using: animationController, and: interactionController,
            animated: animated, interactive: interactive)
        
        // first we release the fromViewController from the layout
        self.containerDelegate?.interactiveTransitioningContainer(self, releaseLayoutOf: fromViewController, inContainerView: self.containerView)
        
        // finally we perform the actual transition
        if !transitionContext.isAnimated {
            
            performNonAnimatedTransition(
                using: transitionContext)
            
        } else if transitionContext.isInteractive {
            
            performInteractiveTransition(
                using: transitionContext, controlledBy: interactionController!)
            
        } else {
            
            performAnimatedTransition(
                using: transitionContext, animatedBy: animationController!)
            
        }
        
    }
    
    // sets selected viewcontroller and calls delegate's callback
    fileprivate func finishTransition(to viewController: UIViewController) {
        
        let cancelled = (self.selectedViewController === viewController)
        
        self.selectedViewController = viewController
        
        containerDelegate?.interactiveTransitioningContainer(self, transitionFinishedTo: viewController, wasCancelled: cancelled)
        
    }
    
}

// MARK: Transition objects creation methods
extension InteractiveTransitioningContainer {
    
    fileprivate func createAnimationPositions(
        forTransitionFrom fromViewController: UIViewController,
        to toViewController: UIViewController
        ) -> InteractiveTransitioningContainerAnimationPositions {
        
        var animationPositions: InteractiveTransitioningContainerAnimationPositions? = containerDelegate?.interactiveTransitioningContainer(self, animationPositionsForTransitionFrom: fromViewController, to: toViewController)
        
        if let animationPositions = animationPositions {
            
            return animationPositions
            
        } else {
            
            return InteractiveTransitioningContainerAnimationPositionsImpl(fromInitialFrame: containerView.frame, fromFinalFrame: containerView.frame, toInitialFrame: containerView.frame, toFinalFrame: containerView.frame)
            
        }
    }
    
    fileprivate func createAnimationController(
        forTransitionFrom fromViewController: UIViewController,
        to toViewController: UIViewController
        ) -> UIViewControllerAnimatedTransitioning? {
        
        // either there is a delegate that is able to give us animator and animation positions,
        // or we won't animate and just use positions driven by the container view
        
        return containerDelegate?.interactiveTransitioningContainer(self, animationControllerForTransitionFrom: fromViewController, to: toViewController)
        
    }
    
    fileprivate func createInteractionController(
        for animator: UIViewControllerAnimatedTransitioning?
        ) -> UIViewControllerInteractiveTransitioning? {
        
        if let animator = animator {
            
            return containerDelegate?.interactiveTransitioningContainer(self, interactionControllerFor: animator)
            
        } else {
            
            return nil
            
        }
        
    }
    
    fileprivate func createTransitionContext(
        forTransitionFrom fromViewController: UIViewController,
        to toViewController: UIViewController,
        using animator: UIViewControllerAnimatedTransitioning?,
        and interactionController: UIViewControllerInteractiveTransitioning?,
        animated: Bool,
        interactive: Bool)
        -> InteractiveTransitioningContainerTransitionContext {
            
        let animationPositions: InteractiveTransitioningContainerAnimationPositions
            = createAnimationPositions(
                forTransitionFrom: fromViewController, to: toViewController)
        
        let transitionContext = InteractiveTransitioningContainerTransitionContext(in: self.containerView, from: fromViewController, to: toViewController, animationPositions: animationPositions)
        
        transitionContext.isAnimated = animated && (animator != nil)
        
        transitionContext.isInteractive = interactive && (interactionController != nil)
        
        // completion block finishes transition lifecycle
        // by contract it has to be called by the animator
        transitionContext.completionBlock = { (didComplete) -> Void in
            
            if didComplete {
                
                self.completeSuccessfulTransition(from: fromViewController, to: toViewController)
                
            } else {
                
                self.completeCancelledTransition(from: fromViewController, to: toViewController)
                
            }
        }
            
        transitionCoordinatorField = transitionContext.transitionCoordinator
            
        return transitionContext
    }
    
}

// MARK: Methods for running prepared transition
extension InteractiveTransitioningContainer {
    
    fileprivate func performNonAnimatedTransition(
        using transitionContext: InteractiveTransitioningContainerTransitionContext) {
        
        transitionContext.completeTransition(true)
        
    }
    
    fileprivate func performAnimatedTransition(
        using transitionContext: InteractiveTransitioningContainerTransitionContext,
        animatedBy animationController: UIViewControllerAnimatedTransitioning) {
        
        if let interruptibleAnimator = animationController.interruptibleAnimator?(using: transitionContext) {
            
            interruptibleAnimator.startAnimation()
            
        } else {
            animationController.animateTransition(using: transitionContext)
        }
        
    }
    
    fileprivate func performInteractiveTransition(
        using transitionContext: InteractiveTransitioningContainerTransitionContext,
        controlledBy interactionController: UIViewControllerInteractiveTransitioning) {
        
        interactionController.startInteractiveTransition(transitionContext)
        
    }
}

// MARK: Completion calls
extension InteractiveTransitioningContainer {

    fileprivate func completeSuccessfulTransition(
        from fromViewController: UIViewController?,
        to toViewController: UIViewController) {
        
        fromViewController?.view.removeFromSuperview()
        fromViewController?.removeFromParentViewController()
        
        self.addAndLayoutToContainerView(viewController: toViewController)
        
        toViewController.didMove(toParentViewController: self)
        
        self.finishTransition(to: toViewController)
        
    }
    
    fileprivate func completeCancelledTransition(
        from fromViewController: UIViewController,
        to toViewController: UIViewController) {
        
        toViewController.view.removeFromSuperview()
        
        // defensive renewal of old fromView, if animator is correctly implemented, this is unnecessary
        self.addAndLayoutToContainerView(viewController: fromViewController)
        
        // do I need this to play nice in context of UIKit?
        // fromViewController.didMove(toParentViewController: self)
        
        self.finishTransition(to: fromViewController)
        
    }
    
    fileprivate func addAndLayoutToContainerView(viewController: UIViewController) {
        
        if viewController.view.superview != self.containerView {
            self.containerView.addSubview(viewController.view)
        }
        
        self.containerDelegate?.interactiveTransitioningContainer(self, layoutIfNotAlready: viewController, inContainerView: self.containerView)
        
    }
}

// MARK: Transition coordinator
extension InteractiveTransitioningContainer {
    
    public override var transitionCoordinator: UIViewControllerTransitionCoordinator?
    {
        return transitionCoordinatorField
    }
    
}

// MARK: status bar overrides - it delegates status bar appearance to child VC
extension InteractiveTransitioningContainer {
    
    public override var prefersStatusBarHidden: Bool {
        return self.selectedViewController?.prefersStatusBarHidden ?? false
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.selectedViewController?.preferredStatusBarStyle ?? .default
    }
    
    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return self.selectedViewController?.preferredStatusBarUpdateAnimation ?? .fade
    }
}
