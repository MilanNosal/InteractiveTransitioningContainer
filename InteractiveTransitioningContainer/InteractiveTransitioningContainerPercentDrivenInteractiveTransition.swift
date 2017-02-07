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
public class InteractiveTransitionContainerPercentDrivenInteractiveTransition: NSObject, UIViewControllerInteractiveTransitioning {
    
    public enum State {
        case isInactive
        case isInteracting
        case isInTearDown
    }
    
    // MARK: UIPercentDrivenInteractiveTransition fields
    public var completionCurve: UIViewAnimationCurve = .linear
    
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
    
    weak var interactiveTransitionContainer: InteractiveTransitioningContainer?
    weak var interactiveTransitionContainerDelegate: InteractiveTransitioningContainerDelegate?
    
    // MARK: Flag reporting the state
    fileprivate(set) var state: State = .isInactive
    
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

    public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        
        assert(self.animator != nil, "Animator object must be set on interactive transitioning context.")
        
        guard state == .isInactive else {
            return
        }
        
        self.state = .isInteracting
        
        self.transitionContext = transitionContext
        
        transitionContext.containerView.layer.speed = 0
        
        self.animator!.animateTransition(using: transitionContext)
    }
    
    func updateInteractiveTransition(percentComplete: CGFloat) {
        
        guard state == .isInteracting else {
            return
        }
        
        let percent = fmin(percentComplete, 1)
        let normalizedPercent = fmax(percent, 0)
        self.percentComplete = normalizedPercent
    }
    
    func cancelInteractiveTransition() {
        
        guard state == .isInteracting else {
            return
        }
        
        self.state = .isInTearDown
        
        transitionContext!.cancelInteractiveTransition()
        
        self.completeTransition()
    }
    
    func finishInteractiveTransition() {
        
        guard state == .isInteracting else {
            return
        }
        
        self.state = .isInTearDown
        
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
            
            // Without this interactive cancelling causes glitching
            transitionContext!.view(forKey: .to)?.removeFromSuperview()
            
            if let interactiveTransitionContainer = interactiveTransitionContainer {
                
                interactiveTransitionContainerDelegate?.interactiveTransitioningContainer(interactiveTransitionContainer, layoutIfNotAlready: transitionContext!.viewController(forKey: .from)!, inContainerView: transitionContext!.containerView)
                
            }
            
        } else {
            
            layer.timeOffset = 0
            layer.beginTime = 0
            
        }
        
        self.state = .isInactive
    }
}
