//
//  InteractiveTransitioningContainerAnimationPositions.swift
//  InteractiveTransitioningContainer
//
//  Created by Milan Nosáľ on 02/02/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import UIKit

protocol InteractiveTransitioningContainerAnimationPositions {
    
    var fromInitialFrame: CGRect { get }
    
    var fromFinalFrame: CGRect { get }
    
    var toInitialFrame: CGRect { get }
    
    var toFinalFrame: CGRect { get }
    
}

struct InteractiveTransitioningContainerAnimationPositionsImpl: InteractiveTransitioningContainerAnimationPositions {
    
    var fromInitialFrame: CGRect
    
    var fromFinalFrame: CGRect
    
    var toInitialFrame: CGRect
    
    var toFinalFrame: CGRect
    
}
