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
class InteractiveTransitioningContainer: UIViewController {
    
    /// Delegate is used for managing all the custom behavior - without the delegate the container
    /// itself is responsible for calling the initial transit, plus all transitions will be forced 
    /// to be non-animated (animator has to be fed using the delegate)
    weak var delegate: InteractiveTransitioningContainerDelegate?
    
    fileprivate(set) var selectedViewController: UIViewController?
    
    fileprivate(set) var containerView: UIView!
    
    
    /// It is the responsibility of the subclass to call transit in viewDidLoad override in order
    /// to present the initial view
    func transit(to viewController: UIViewController, animated: Bool = true) {
        
        self.transit(from: selectedViewController, to: viewController, animated: animated)
        
    }
    
}

// MARK: Initialization
extension InteractiveTransitioningContainer {
    
    override func loadView() {
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let delegate = delegate {
            transit(to: delegate.initialViewController(interactiveTransitioningContainer: self))
        }
        
    }
    
}

// MARK: transitioning
extension InteractiveTransitioningContainer {
    
    fileprivate func transit(from fromViewController: UIViewController?, to toViewController: UIViewController, animated: Bool = true) {
        
        guard toViewController != fromViewController && self.isViewLoaded else {
            return
        }
        
        // start of transition lifecycle
        fromViewController?.willMove(toParentViewController: nil)
        self.addChildViewController(toViewController)
        
        // If this is the initial presentation, add the new child with no animation
        guard let fromViewController = fromViewController else {
            
            self.containerView.addSubview(toViewController.view)
            
            // opportunity to set frame, add autolayout constraints, etc.
            delegate?.interactiveTransitioningContainer(interactiveTransitioningContainer: self, layoutViewController: toViewController, inContainerView: self.containerView)
            
            toViewController.didMove(toParentViewController: self)
            finishTransition(to: toViewController)
            
            return
        }
        
        // either there is a delegate that is able to give us animator and animation positions,
        // or we won't animate and just use positions driven by the container view
        let animator: UIViewControllerAnimatedTransitioning? = delegate?.interactiveTransitioningContainer(interactiveTransitioningContainer: self, animationControllerForTransitionFrom: fromViewController, to: toViewController)
        
        let animationPositions: InteractiveTransitioningContainerAnimationPositions
            = delegate?.interactiveTransitioningContainer(interactiveTransitioningContainer: self, animationPositionsForTransitionFrom: fromViewController, to: toViewController)
            ??
            InteractiveTransitioningContainerAnimationPositionsImpl(fromInitialFrame: containerView.frame, fromFinalFrame: containerView.frame, toInitialFrame: containerView.frame, toFinalFrame: containerView.frame)
            
        let transitionContext = InteractiveTransitioningContainerTransitionContext(in: self.containerView, from: fromViewController, to: toViewController, animationPositions: animationPositions)
        
        transitionContext.isAnimated = animated && (animator != nil)
        
        let interactionController = (animator != nil) ? delegate?.interactiveTransitioningContainer(interactiveTransitioningContainer: self, interactionControllerFor: animator!) : nil
        
        transitionContext.isInteractive = (interactionController != nil)
        
        // completion block finishes transition lifecycle
        // by contract it has to be called by the animator
        transitionContext.completionBlock = { (didComplete) -> Void in
            
            if didComplete {
                
                fromViewController.view.removeFromSuperview()
                fromViewController.removeFromParentViewController()
                
                if toViewController.view.superview != self.containerView {
                    self.containerView.addSubview(toViewController.view)
                }
                
                // opportunity to set frame, add autolayout constraints, etc.
                self.delegate?.interactiveTransitioningContainer(interactiveTransitioningContainer: self, layoutViewController: toViewController, inContainerView: self.containerView)
                
                toViewController.didMove(toParentViewController: self)
                
                self.finishTransition(to: toViewController)
                
            } else {
                
                toViewController.view.removeFromSuperview()
                
                // defensive renewal of old fromView
                if fromViewController.view.superview != self.containerView {
                    self.containerView.addSubview(fromViewController.view)
                }
                
                self.delegate?.interactiveTransitioningContainer(interactiveTransitioningContainer: self, layoutViewController: fromViewController, inContainerView: self.containerView)
                
                // do I need this to play nice?
//                fromViewController.didMove(toParentViewController: self)
                
                self.finishTransition(to: fromViewController)
                
            }
        }
        
        if !transitionContext.isAnimated {
            // we support also non-animated transitions
            fromViewController.view.removeFromSuperview()
            self.containerView.addSubview(toViewController.view)
            
            transitionContext.completeTransition(true)
            
        } else if transitionContext.isInteractive {
            
            interactionController!.startInteractiveTransition(transitionContext)
            
        } else {
            
            // if it is animated, animator has to have a value
            animator!.animateTransition(using: transitionContext)
            
        }
    }
    
    // sets selected vie controller and calls delegate's callback
    fileprivate func finishTransition(to viewController: UIViewController) {
        
        let cancelled = self.selectedViewController === viewController
        
        self.selectedViewController = viewController
        
        delegate?.interactiveTransitioningContainer(interactiveTransitioningContainer: self, transitionFinishedTo: viewController, wasCancelled: cancelled)
        
    }
    
}

// MARK: status bar overrides - it delegates status bar appearance to child VC
extension InteractiveTransitioningContainer {
    
    override var prefersStatusBarHidden: Bool {
        return self.selectedViewController?.prefersStatusBarHidden ?? false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.selectedViewController?.preferredStatusBarStyle ?? .default
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return self.selectedViewController?.preferredStatusBarUpdateAnimation ?? .fade
    }
}
