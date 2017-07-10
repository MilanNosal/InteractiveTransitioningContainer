//
//  SwipeToSlideTabBarContainer.swift
//  InteractiveTransitioningContainer
//
//  Created by Milan Nosáľ on 06/03/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import UIKit

public protocol SwipeToSlideTabBarContainerDelegate: class {
    
    func swipeToSlideTabBarContainer(
        _ swipeToSlideTabBarContainer: SwipeToSlideTabBarContainer,
        didFinishTransitionToIndex selectedIndex: Int,
        wasCancelled: Bool)
    
    
    func swipeToSlideTabBarContainer(
        _ swipeToSlideTabBarContainer: SwipeToSlideTabBarContainer,
        willTransitionFromIndex fromIndex: Int,
        to toIndex: Int,
        coordinatedBy transitionCoordinator: UIViewControllerTransitionCoordinator)
    
}

public class SwipeToSlideTabBarContainer: UIViewController {
    
    fileprivate let tabBarChildControllers: [SwipeToSlideTabBarChildController]
    
    fileprivate let containerViewController: SwipeToSlideInteractiveTransitioningContainer
    
    fileprivate let tabBarViewController: SwipeToSlideTabBarViewController
    
    fileprivate var selectedIndex: Int
    
    fileprivate let tabBarOnTop: Bool
    
    
    public weak var delegate: SwipeToSlideTabBarContainerDelegate?
    
    public init(with tabBarChildControllers: [SwipeToSlideTabBarChildController],
         initiallySelected selectedIndex: Int = 0,
         tabBarOnTop: Bool = true) {
        self.tabBarChildControllers = tabBarChildControllers
        let childViewControllers = tabBarChildControllers.map({ $0.childViewController })
        self.containerViewController = SwipeToSlideInteractiveTransitioningContainer(with: childViewControllers)
        self.selectedIndex = selectedIndex
        let tabBarItems = tabBarChildControllers.map { $0.tabBarItem }
        self.tabBarViewController = SwipeToSlideTabBarViewController(with: tabBarItems)
        self.tabBarOnTop = tabBarOnTop
        super.init(nibName: nil, bundle: nil)
        self.containerViewController.delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        layoutComponents()
        setAttributes()
        applyConstraints()
    }
    
    fileprivate func layoutComponents() {
        view.addSubview(tabBarViewController.view)
        view.addSubview(containerViewController.view)
    }
    
    fileprivate func setAttributes() {
        view.backgroundColor = .clear
        view.isOpaque = true
    }
    
    fileprivate func applyConstraints() {
        
        tabBarViewController.view!.translatesAutoresizingMaskIntoConstraints = false
        containerViewController.view!.translatesAutoresizingMaskIntoConstraints = false
        
        if self.tabBarOnTop {
            applyLayoutConstraintsWhenTabBarOnTop()
        } else {
            applyLayoutConstraintsWhenTabBarAtBottom()
        }
    }
    
    fileprivate func applyLayoutConstraintsWhenTabBarOnTop() {
        let tabBarView = tabBarViewController.view!
        let containerView = containerViewController.view!
        NSLayoutConstraint.activate([
            tabBarView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor),
            tabBarView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            tabBarView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            
            tabBarView.bottomAnchor.constraint(equalTo: containerView.topAnchor),
            
            containerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            containerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor)
            ])
    }
    
    fileprivate func applyLayoutConstraintsWhenTabBarAtBottom() {
        let tabBarView = tabBarViewController.view!
        let containerView = containerViewController.view!
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor),
            containerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            containerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            
            containerView.bottomAnchor.constraint(equalTo: tabBarView.topAnchor),
            
            tabBarView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            tabBarView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            tabBarView.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor)
            ])
    }
}

extension SwipeToSlideTabBarContainer: SwipeToSlideInteractiveTransitioningContainerDelegate {
    
    public func swipeToSlideInteractiveTransitioningContainer(
        _ swipeToSlideInteractiveTransitioningContainer: SwipeToSlideInteractiveTransitioningContainer,
        didFinishTransitionToIndex selectedIndex: Int, wasCancelled: Bool) {
        self.selectedIndex = selectedIndex
        delegate?.swipeToSlideTabBarContainer(self, didFinishTransitionToIndex: selectedIndex, wasCancelled: wasCancelled)
    }
    
    public func swipeToSlideInteractiveTransitioningContainer(
        _ swipeToSlideInteractiveTransitioningContainer: SwipeToSlideInteractiveTransitioningContainer,
        willTransitionFromIndex fromIndex: Int, to toIndex: Int,
        coordinatedBy transitionCoordinator: UIViewControllerTransitionCoordinator) {
        delegate?.swipeToSlideTabBarContainer(self, willTransitionFromIndex: fromIndex, to: toIndex, coordinatedBy: transitionCoordinator)
    }
}

// MARK: status bar overrides
extension SwipeToSlideTabBarContainer {
    override public var prefersStatusBarHidden: Bool {
        return self.containerViewController.prefersStatusBarHidden
    }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return self.containerViewController.preferredStatusBarStyle
    }
    
    override public var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return self.containerViewController.preferredStatusBarUpdateAnimation
    }
}
