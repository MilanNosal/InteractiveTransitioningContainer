//
//  UIViewController.swift
//  InteractiveTransitioningContainer
//
//  Created by Milan Nosáľ on 09/02/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import UIKit

public protocol InteractiveTransitioningContainerChild {
    weak var containerTransitionCoordinator: UIViewControllerTransitionCoordinator? { get }
}

extension UIViewController: InteractiveTransitioningContainerChild {
    public var containerTransitionCoordinator: UIViewControllerTransitionCoordinator? {
        return self.parent?.transitionCoordinator
    }
}
