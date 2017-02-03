//
//  InteractiveTransitioningContainerPercentDrivenInteractiveTransition.swift
//  InteractiveTransitioningContainer
//
//  Created by Milan Nosáľ on 22/01/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import Foundation

// Custom percent driven interactive transition object - should be inherited from when used with InteractiveTransitioningContainer
// I've had some problems with the original implementation of Alek Akstrom, so I use this slight modification
//
// Credits also to Alek Akstrom
// - http://www.iosnomad.com/blog/2014/5/12/interactive-custom-container-view-controller-transitions
class InteractiveTransitionContainerPercentDrivenInteractiveTransition: NSObject, UIViewControllerInteractiveTransitioning {
    
    // MARK: UIPercentDrivenInteractiveTransition fields
    var completionCurve: UIViewAnimationCurve = .linear
    
    // Duration is delegated to the animator
    var duration: CGFloat {
        return CGFloat(animator!.transitionDuration(using: transitionContext!))
    }
    
    var percentComplete: CGFloat {
        didSet {
            
            let offset = TimeInterval(percentComplete * duration)
            self.timeOffset = offset
            
            transitionContext!.updateInteractiveTransition(percentComplete)
        }
    }
    
    public var completionSpeed: CGFloat = 1
    
    
    // MARK: Internal fields
    fileprivate var timeOffset: TimeInterval {
        set {
            transitionContext!.containerView.layer.timeOffset = newValue
        }
        get {
            return transitionContext!.containerView.layer.timeOffset
        }
    }
    
    fileprivate var displayLink: CADisplayLink?
    
    // MARK: Context fields
    weak var animator: UIViewControllerAnimatedTransitioning?
    
    weak var transitionContext: UIViewControllerContextTransitioning?
    
    // MARK: Flags reporting the state
    fileprivate(set) var isInInteraction: Bool = false
    
    fileprivate(set) var isInTearDown = false
    
    // MARK: Initializers
    convenience init(with animator: UIViewControllerAnimatedTransitioning) {
        self.init()
        self.animator = animator
    }
    
    override init() {
        percentComplete = 0
        super.init()
    }
}

// MARK:
extension InteractiveTransitionContainerPercentDrivenInteractiveTransition {

    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        
        assert(self.animator != nil, "Animator object must be set on interactive transitioning context.")
        
        self.isInTearDown = false
        self.isInInteraction = true
        
        self.transitionContext = transitionContext
        
        transitionContext.containerView.layer.speed = 0
        
        self.animator!.animateTransition(using: transitionContext)
    }
    
    func updateInteractiveTransition(percentComplete: CGFloat) {
        
        guard isInInteraction else {
            return
        }
        
        let percent = fmin(percentComplete, 1)
        let normalizedPercent = fmax(percent, 0)
        self.percentComplete = normalizedPercent
    }
    
    func cancelInteractiveTransition() {
        
        guard isInInteraction else {
            return
        }
        
        self.isInTearDown = true
        
        transitionContext!.cancelInteractiveTransition()
        
        self.completeTransition()
    }
    
    func finishInteractiveTransition() {
        
        guard isInInteraction else {
            return
        }
        
        self.isInTearDown = true
        
        transitionContext!.finishInteractiveTransition()
        
        self.completeTransition()
    }
}

// MARK: Internal methods
extension InteractiveTransitionContainerPercentDrivenInteractiveTransition {
    
    fileprivate func completeTransition() {
        
        displayLink = CADisplayLink(target: self, selector: #selector(InteractiveTransitionContainerPercentDrivenInteractiveTransition.tickAnimation))
        displayLink!.add(to: RunLoop.main, forMode: .commonModes)
        
    }
    
    @objc fileprivate func tickAnimation() {
        
        var timeOffset = self.timeOffset
        let tick = displayLink!.duration * CFTimeInterval(self.completionSpeed)
        timeOffset = timeOffset + (transitionContext!.transitionWasCancelled ? -tick : tick)
        
        if timeOffset < 0 || timeOffset > TimeInterval(self.duration) {
            self.transitionFinished()
        } else {
            self.timeOffset = timeOffset
        }
    }
    
    fileprivate func transitionFinished() {
        
        displayLink!.invalidate()
        
        let layer = transitionContext!.containerView.layer
        layer.speed = 1
        
        if transitionContext!.transitionWasCancelled {
            
            // Without this interactive cancelling cause glitching
            
            // TODO: refactor
            transitionContext!.view(forKey: .to)?.removeFromSuperview()
            transitionContext!.view(forKey: .from)?.transform = CGAffineTransform.identity
            
        } else {
            
            layer.timeOffset = 0
            layer.beginTime = 0
            
        }
        
        self.isInInteraction = false
        self.isInTearDown = false
    }
}
