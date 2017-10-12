//
//  SwipeToSlideTabBarViewController.swift
//  InteractiveTransitioningContainer
//
//  Created by Milan Nosáľ on 12/04/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import UIKit

class SwipeToSlideTabBarViewController: UIViewController {
    
    let tabBarItems: [SwipeToSlideTabBarItem]
    
    // MARK: view properties
    
    var wantsExpansion: Bool {
        didSet {
            UIView.animate(withDuration: 0.2, animations: {
                self.titleView.isHidden = !self.wantsExpansion
            })
        }
    }
    
    fileprivate var tabBarView: UIStackView!
    
    fileprivate let titleView = UIView()
    
    fileprivate var buttonsStack: UIStackView!
    
    fileprivate var navigationButtons: [UIButton] = []
    
    fileprivate let navigationCursor: UIView = UIView()
    
    // MARK: initialization
    
    init(with tabBarItems: [SwipeToSlideTabBarItem], initiallySelected selectedIndex: Int = 0) {
        self.tabBarItems = tabBarItems
        self.wantsExpansion = true
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .red
        
//        self.view.backgroundColor = .clear
//        self.view.isOpaque = true
        
        view.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }

}
