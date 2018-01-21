//
//  InteractiveTransitioningContainerAnimationPositions.swift
//  InteractiveTransitioningContainer
//
//  Created by Milan Nosáľ on 02/02/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import UIKit

public protocol InteractiveTransitioningContainerAnimationPositions {
    
    var fromInitialFrame: CGRect { get }
    
    var fromFinalFrame: CGRect { get }
    
    var toInitialFrame: CGRect { get }
    
    var toFinalFrame: CGRect { get }
    
}

public struct InteractiveTransitioningContainerAnimationPositionsImpl: InteractiveTransitioningContainerAnimationPositions, CustomStringConvertible {
    
    public var fromInitialFrame: CGRect
    
    public var fromFinalFrame: CGRect
    
    public var toInitialFrame: CGRect
    
    public var toFinalFrame: CGRect
    
    public init(fromInitialFrame: CGRect, fromFinalFrame: CGRect, toInitialFrame: CGRect, toFinalFrame: CGRect) {
        self.fromInitialFrame = fromInitialFrame
        self.fromFinalFrame = fromFinalFrame
        self.toInitialFrame = toInitialFrame
        self.toFinalFrame = toFinalFrame
    }
    
    public var description: String {
        return "Old going from (\(fromInitialFrame)) to (\(fromFinalFrame))\nNew going from (\(toInitialFrame)) to (\(toFinalFrame))"
    }
}
