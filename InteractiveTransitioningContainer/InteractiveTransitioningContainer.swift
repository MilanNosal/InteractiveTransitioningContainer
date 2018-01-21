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
open class InteractiveTransitioningContainer: UIViewController {
    
    /// Delegate is used for managing all the custom behavior
    /// For the initial VC to be set up correctly, provide the delegate before 
    /// viewDidLoad is called (either in loadView, or before calling super.viewDidLoad in subclass)
    /// Reference to containerDelegate is weak
    open weak var containerDelegate: InteractiveTransitioningContainerDelegate?
    
    fileprivate(set) public var selectedViewController: UIViewController!
    
    public var containerView: UIView!
    
    fileprivate weak var transitionCoordinatorField: InteractiveTransitioningContainerTransitionCoordinator?
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public convenience init(withContainerDelegate containerDelegate: InteractiveTransitioningContainerDelegate) {
        self.init()
        self.containerDelegate = containerDelegate
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func transition(to viewController: UIViewController, animated: Bool = true, interactive: Bool = false) {
        guard selectedViewController != nil else {
            self.transition(toInitialViewController: viewController)
            return
        }
        
        self.transition(from: selectedViewController, to: viewController, animated: animated, interactive: interactive)
    }

    // MARK: Initialization
    
    // It is required that you call super.loadView at the beginning of overriding implementation of loadView
    open override func loadView() {
        super.loadView()
        
        self.containerView = self.view
        setupHierarchy()
        setupAtributes()
        setupLayout()
    }
    
    /// If the delegate is already set, the initialViewController is loaded into view
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if let initialViewController = containerDelegate?.initialViewController(self) {
            transition(toInitialViewController: initialViewController)
        }
    }
    
    private func setupHierarchy() {
        
    }
    
    private func setupAtributes() {
        view.backgroundColor = .clear
        view.isOpaque = true
    }
    
    fileprivate func setupLayout() {
        
    }
    
    // MARK: Transition coordinator
    open override var transitionCoordinator: UIViewControllerTransitionCoordinator? {
        return transitionCoordinatorField
    }
    
    // MARK: status bar overrides - it delegates status bar appearance to child VC
    open override var prefersStatusBarHidden: Bool {
        return self.selectedViewController?.prefersStatusBarHidden ?? false
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.selectedViewController?.preferredStatusBarStyle ?? .default
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return self.selectedViewController?.preferredStatusBarUpdateAnimation ?? .fade
    }
    
    // MARK: Layout override
    open override func viewDidLayoutSubviews() {
//        self.containerDelegate?.interactiveTransitioningContainer(self, layoutIfNotAlready: selectedViewController, inContainerView: self.containerView)
        
        super.viewDidLayoutSubviews()
    }
}

// MARK: Load initial viewControlled child
extension InteractiveTransitioningContainer {
    fileprivate func transition(toInitialViewController initialViewController: UIViewController) {
        guard self.isViewLoaded else {
            return
        }
        
        self.addChildViewController(initialViewController)
        
        self.containerView.addSubview(initialViewController.view)
        self.containerDelegate?.interactiveTransitioningContainer(self, layoutIfNotAlready: initialViewController, inContainerView: self.containerView)
        initialViewController.didMove(toParentViewController: self)
        
        finishTransition(to: initialViewController)
    }
}

// MARK: Transitions between childs
extension InteractiveTransitioningContainer {
    fileprivate func transition(
        from fromViewController: UIViewController,
        to toViewController: UIViewController,
        animated: Bool, interactive: Bool) {
        
        assert(!(!animated && interactive), "Non-animated transition cannot be interactive!")
        
        guard toViewController != fromViewController && self.isViewLoaded else {
            return
        }
        
        // prepare transition controllers
        let animationController = createAnimationController(forTransitionFrom: fromViewController, to: toViewController)
        let interactionController = createInteractionController(for: animationController)
        let transitionContext = createTransitionContext(
            forTransitionFrom: fromViewController, to: toViewController,
            using: animationController, and: interactionController,
            animated: animated, interactive: interactive)
        
        self.containerDelegate?.interactiveTransitioningContainer(self, willTransitionFrom: fromViewController, to: toViewController, coordinatedBy: transitionContext.transitionCoordinator)
        
        beginTransition(from: fromViewController, to: toViewController, animated: transitionContext.isAnimated)
        
        performTransition(using: transitionContext, animatedBy: animationController, controlledBy: interactionController)
    }
}

// MARK: Animation controllers' factory methods
extension InteractiveTransitioningContainer {

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
        interactive: Bool
        ) -> InteractiveTransitioningContainerTransitionContext {
            
        let animationPositions = createAnimationPositions(
                forTransitionFrom: fromViewController, to: toViewController)
        
        let transitionContext = InteractiveTransitioningContainerTransitionContext(in: self.containerView, from: fromViewController, to: toViewController, animationPositions: animationPositions)
        transitionContext.isAnimated = animated && (animator != nil)
        transitionContext.isInteractive = interactive && (interactionController != nil)
        
        // completion block finishes transition lifecycle
        // by contract it has to be called by the animator
        transitionContext.completionBlock = {[weak transitionContext] (didComplete) -> Void in
            if didComplete {
                self.completeSuccessfulTransition(from: fromViewController, to: toViewController)
            } else {
                self.completeCancelledTransition(from: fromViewController, to: toViewController, using: transitionContext)
            }
        }
        self.transitionCoordinatorField = transitionContext.transitionCoordinator
        return transitionContext
    }
    
    fileprivate func createAnimationPositions(
        forTransitionFrom fromViewController: UIViewController,
        to toViewController: UIViewController
        ) -> InteractiveTransitioningContainerAnimationPositions {
        
        let animationPositions: InteractiveTransitioningContainerAnimationPositions? = containerDelegate?.interactiveTransitioningContainer(self, animationPositionsForTransitionFrom: fromViewController, to: toViewController)
        
        if let animationPositions = animationPositions {
            return animationPositions
        } else {
            return InteractiveTransitioningContainerAnimationPositionsImpl(fromInitialFrame: containerView.frame, fromFinalFrame: containerView.frame, toInitialFrame: containerView.frame, toFinalFrame: containerView.frame)
        }
    }
}

// MARK: Transition lifecycle methods
extension InteractiveTransitioningContainer {
    
    fileprivate func beginTransition(
        from fromViewController: UIViewController,
        to toViewController: UIViewController,
        animated: Bool) {
        
        fromViewController.willMove(toParentViewController: nil)
        fromViewController.beginAppearanceTransition(false, animated: animated)
        self.containerDelegate?.interactiveTransitioningContainer(self, releaseLayoutOf: fromViewController, inContainerView: self.containerView)
        
        self.addChildViewController(toViewController)
        toViewController.beginAppearanceTransition(true, animated: animated)
    }
    
    fileprivate func performTransition(
        using transitionContext: InteractiveTransitioningContainerTransitionContext,
        animatedBy animationController: UIViewControllerAnimatedTransitioning?,
        controlledBy interactionController: UIViewControllerInteractiveTransitioning?) {
        
        prepareAnimationControllerIfNeeded(animationController, using: transitionContext)
        
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
    
    fileprivate func prepareAnimationControllerIfNeeded(
        _ animationController: UIViewControllerAnimatedTransitioning?,
        using transitionContext: InteractiveTransitioningContainerTransitionContext) {
        
        guard let interruptibleAnimator = animationController?.interruptibleAnimator?(using: transitionContext) else {
            return
        }
        
        interruptibleAnimator.addAnimations! { [weak self] in
            self?.transitionCoordinatorField?.performAlongsideAnimations()
        }
        interruptibleAnimator.addCompletion!({ [weak self] (animatingPositions) in
            self?.transitionCoordinatorField?.completeTransition()
        })
    }
}

// MARK: Transition completion methods
extension InteractiveTransitioningContainer {
    
    fileprivate func completeSuccessfulTransition(
        from fromViewController: UIViewController,
        to toViewController: UIViewController) {
        
        completeRemoving(fromViewController: fromViewController)
        completeAdding(toViewController: toViewController)
        finishTransition(to: toViewController)
    }
    
    fileprivate func completeRemoving(fromViewController: UIViewController) {
        fromViewController.view.removeFromSuperview()
        fromViewController.removeFromParentViewController()
        fromViewController.endAppearanceTransition()
    }
    
    fileprivate func completeAdding(toViewController: UIViewController) {
        if toViewController.view.superview != self.containerView {
            self.containerView.addSubview(toViewController.view)
        }
        self.containerDelegate?.interactiveTransitioningContainer(self, layoutIfNotAlready: toViewController, inContainerView: self.containerView)
        toViewController.didMove(toParentViewController: self)
        toViewController.endAppearanceTransition()
    }
    
    fileprivate func completeCancelledTransition(
        from fromViewController: UIViewController,
        to toViewController: UIViewController,
        using transitionContext: InteractiveTransitioningContainerTransitionContext?) {
        
        let animated = transitionContext?.isAnimated ?? false
        cancelAdding(toViewController: toViewController, animated: animated)
        cancelRemoving(fromViewController: fromViewController, animated: animated)
        self.finishTransition(to: fromViewController)
    }
    
    fileprivate func cancelAdding(toViewController: UIViewController, animated: Bool) {
        toViewController.beginAppearanceTransition(false, animated: animated)
        toViewController.view.removeFromSuperview()
        toViewController.removeFromParentViewController()
        toViewController.endAppearanceTransition()
    }
    
    fileprivate func cancelRemoving(fromViewController: UIViewController, animated: Bool) {
        fromViewController.beginAppearanceTransition(true, animated: animated)
        if fromViewController.view.superview != self.containerView {
            self.containerView.addSubview(fromViewController.view)
        }
        self.containerDelegate?.interactiveTransitioningContainer(self, layoutIfNotAlready: fromViewController, inContainerView: self.containerView)
        fromViewController.didMove(toParentViewController: self)
        fromViewController.endAppearanceTransition()
    }
    
    
    fileprivate func finishTransition(to viewController: UIViewController) {
        self.selectedViewController = viewController
        
        let wasCancelled = (self.selectedViewController === viewController)
        containerDelegate?.interactiveTransitioningContainer(self, transitionFinishedTo: viewController, wasCancelled: wasCancelled)
    }
}
