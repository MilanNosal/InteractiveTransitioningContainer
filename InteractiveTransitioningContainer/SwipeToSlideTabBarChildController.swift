//
//  SwipeToSlideTabBarChildController.swift
//  InteractiveTransitioningContainer
//
//  Created by Milan Nosáľ on 06/03/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import Foundation

public struct SwipeToSlideTabBarItem {
    let title: String
    let image: UIImage
    let backgroundColor: UIColor
    
    public init(title: String, image: UIImage, backgroundColor: UIColor) {
        self.title = title
        self.image = image
        self.backgroundColor = backgroundColor
    }
}

public struct SwipeToSlideTabBarChildController {
    let tabBarItem: SwipeToSlideTabBarItem
    let childViewController: UIViewController
    
    public init(tabBarItemTitle: String, tabBarItemImage: UIImage, tabBarBackgroundColor: UIColor, childViewController: UIViewController) {
        self.tabBarItem = SwipeToSlideTabBarItem(title: tabBarItemTitle, image: tabBarItemImage, backgroundColor: tabBarBackgroundColor)
        self.childViewController = childViewController
    }
}
