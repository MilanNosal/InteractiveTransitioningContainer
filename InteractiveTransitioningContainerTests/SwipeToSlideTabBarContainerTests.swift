//
//  SwipeToSlideTabBarContainer.swift
//  InteractiveTransitioningContainer
//
//  Created by Milan Nosáľ on 06/03/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import XCTest
@testable import InteractiveTransitioningContainer

class SwipeToSlideTabBarContainerTests: XCTestCase {
    
    let tabBarChilds = [
        SwipeToSlideTabBarChildController(menuItemTitle: "home", menuItemImage: UIImage(), childViewController: UIViewController()),
        SwipeToSlideTabBarChildController(menuItemTitle: "profile", menuItemImage: UIImage(), childViewController: UIViewController()),
        SwipeToSlideTabBarChildController(menuItemTitle: "settings", menuItemImage: UIImage(), childViewController: UIViewController())
    ]
    
    var sut: SwipeToSlideTabBarContainer!
    
    override func setUp() {
        super.setUp()
        
        sut = SwipeToSlideTabBarContainer(with: tabBarChilds)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_sut_successfullyCreated() {
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.selectedIndex, 0)
    }
    
//    func test
    
    
}
