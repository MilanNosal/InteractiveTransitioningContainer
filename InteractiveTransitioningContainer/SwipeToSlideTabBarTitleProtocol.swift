//
//  SwipeToSlideTabBarTitleProtocol.swift
//  InteractiveTransitioningContainer
//
//  Created by Milan Nosáľ on 26/04/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import Foundation

public protocol SwipeToSlideTabBarTitleProtocol {
    
    func prepareForTransition(to toIndex: Int)
    
    func transition(to toIndex: Int)
    
}
