//
//  UIView.swift
//  InteractiveTransitioningContainer
//
//  Created by Milan Nosáľ on 06/02/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import UIKit

extension UIView {
    
    // Utility method to provide an easier way to create constraints
    func pinToSuperViewConstraints(left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat) -> [NSLayoutConstraint] {
        guard superview != nil else {
            fatalError("pinToSuperView method requires the view to be added to its superview.")
        }
        return [
            self.superview!.leftAnchor.constraint(equalTo: self.leftAnchor, constant: -left),
            self.superview!.topAnchor.constraint(equalTo: self.topAnchor, constant: -top),
            self.superview!.rightAnchor.constraint(equalTo: self.rightAnchor, constant: right),
            self.superview!.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: bottom)
        ]
    }
}
