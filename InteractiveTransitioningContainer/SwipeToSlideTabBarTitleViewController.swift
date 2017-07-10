//
//  SwipeToSlideTabBarTitleViewController.swift
//  InteractiveTransitioningContainer
//
//  Created by Milan Nosáľ on 26/04/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import UIKit

class SwipeToSlideTabBarTitleViewController: UIViewController, SwipeToSlideTabBarTitleProtocol {
    
    private let titles: [NSAttributedString]
    private var titleLabels: [UILabel] = []
    
    private var rightTransform: CGAffineTransform!
    private var leftTransform: CGAffineTransform!
    
    fileprivate var selectedIndex: Int
    
    init(with titles: [NSAttributedString], selectedIndex: Int) {
        self.titles = titles
        self.selectedIndex = selectedIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareProperties()
        layoutComponents()
        setAttributes()
        applyConstraints()
    }
    
    fileprivate func prepareProperties() {
        rightTransform = CGAffineTransform(translationX: view.bounds.width, y: 0)
        leftTransform = CGAffineTransform(translationX: -view.bounds.width, y: 0)
        
        for title in titles {
            let newTitleLabel = UILabel()
            newTitleLabel.attributedText = title
            titleLabels.append(newTitleLabel)
        }
    }
    
    fileprivate func layoutComponents() {
        for titleLabel in titleLabels {
            view.addSubview(titleLabel)
        }
    }
    
    fileprivate func setAttributes() {
        for titleLabel in titleLabels {
            titleLabel.transform = rightTransform
        }
        
        titleLabels[selectedIndex].transform = CGAffineTransform.identity
    }
    
    fileprivate func applyConstraints() {
        for titleLabel in titleLabels {
            
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: view.topAnchor),
                titleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15)
                ])
        }
    }
    
    func prepareForTransition(to toIndex: Int) {
        if selectedIndex < toIndex {
            for index in (selectedIndex + 1) ..< toIndex {
                titleLabels[index].transform = leftTransform
            }
        } else if selectedIndex > toIndex {
            for index in (toIndex + 1) ..< selectedIndex {
                titleLabels[index].transform = rightTransform
            }
        }
    }
    
    func transition(to toIndex: Int) {
        if selectedIndex < toIndex {
            titleLabels[selectedIndex].transform = leftTransform
            titleLabels[toIndex].transform = CGAffineTransform.identity
        } else if selectedIndex > toIndex {
            titleLabels[selectedIndex].transform = rightTransform
            titleLabels[toIndex].transform = CGAffineTransform.identity
        }
        selectedIndex = toIndex
    }

}
