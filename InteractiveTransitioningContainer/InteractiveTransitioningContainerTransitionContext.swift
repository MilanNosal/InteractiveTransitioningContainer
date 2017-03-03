//
//  InteractiveTransitioningContainerTransitionContext.swift
//  InteractiveTransitioningContainer
//
//  Created by Milan Nosáľ on 22/01/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import UIKit

// Our context implementation to mimick UIKit containers and play nicely with existing animators
// and interactive controllers
//
// Credits also to Joachim Bondo
// - https://www.objc.io/issues/12-animations/custom-container-view-controller-transitions/
// and Alek Akstrom
// - http://www.iosnomad.com/blog/2014/5/12/interactive-custom-container-view-controller-transitions
//
class InteractiveTransitioningContainerTransitionContext: NSObject, UIViewControllerContextTransitioning {
    // MARK: UIViewControllerContextTransitioning fields
    var containerView: UIView
    
    var presentationStyle: UIModalPresentationStyle
    
    var transitionWasCancelled: Bool = false {
        didSet {
            transitionCoordinator.isCancelled = self.transitionWasCancelled
        }
    }
    
    var targetTransform: CGAffineTransform = CGAffineTransform.identity {
        didSet {
            transitionCoordinator.targetTransform = self.targetTransform
        }
    }
    
    var isAnimated: Bool = false {
        didSet {
            transitionCoordinator.isAnimated = self.isAnimated
        }
    }
    
    var isInteractive: Bool = false {
        didSet {
            transitionCoordinator.isInteractive = self.isInteractive
            transitionCoordinator.initiallyInteractive = self.isInteractive
        }
    }
    
    // MARK: Internal fields
    fileprivate var viewControllers: [UITransitionContextViewControllerKey:UIViewController]
    fileprivate var views: [UITransitionContextViewKey:UIView]
    
    var percentComplete: CGFloat = 0
    
    // MARK: Transition info fields
    fileprivate let animationPositions: InteractiveTransitioningContainerAnimationPositions
    
    var completionBlock: ((_ didComplete: Bool) -> Void)?
    
    // transitionContext will be responsible for keeping coordinator up-to-date
    let transitionCoordinator: InteractiveTransitioningContainerTransitionCoordinator
    
    // MARK: Initializer
    init(
        in containerView: UIView,
        from fromViewController: UIViewController,
        to toViewController: UIViewController,
        animationPositions: InteractiveTransitioningContainerAnimationPositions) {
        
        self.presentationStyle = .custom
        self.containerView = containerView
        self.viewControllers = [
            UITransitionContextViewControllerKey.from: fromViewController,
            UITransitionContextViewControllerKey.to: toViewController
        ]
        self.views = [
            UITransitionContextViewKey.from: fromViewController.view,
            UITransitionContextViewKey.to: toViewController.view
        ]
        
        self.animationPositions = animationPositions
        
        transitionCoordinator = InteractiveTransitioningContainerTransitionCoordinator(in: self.containerView, from: fromViewController, to: toViewController)
        
        super.init()
    }
}

// MARK: Implementation of UIViewControllerContextTransitioning methods
extension InteractiveTransitioningContainerTransitionContext {
    
    func initialFrame(for vc: UIViewController) -> CGRect {
        if vc == viewController(forKey: .from) {
            return animationPositions.fromInitialFrame
        } else {
            return animationPositions.toInitialFrame
        }
    }
    
    func finalFrame(for vc: UIViewController) -> CGRect {
        if vc == viewController(forKey: .from) {
            return animationPositions.fromFinalFrame
        } else {
            return animationPositions.toFinalFrame
        }
    }
    
    func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
        return viewControllers[key]
    }
    
    func view(forKey key: UITransitionContextViewKey) -> UIView? {
        return views[key]
    }
    
    func completeTransition(_ didComplete: Bool) {
        self.completionBlock?(didComplete)
    }
    
    func updateInteractiveTransition(_ percentComplete: CGFloat) {
        self.percentComplete = percentComplete
    }
    
    func finishInteractiveTransition() {
        self.transitionCoordinator.notifyThatInteractionStopped()
        self.transitionWasCancelled = false
    }
    
    func cancelInteractiveTransition() {
        self.transitionCoordinator.notifyThatInteractionStopped()
        self.transitionWasCancelled = true
    }
    
    func pauseInteractiveTransition() {
        
    }
}
