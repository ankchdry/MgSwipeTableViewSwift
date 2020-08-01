//
//  MGSwipeExpansionSettings.swift
//  MgSwipeTableViewSwift
//
//  Created by Ankit Chaudhary on 31/07/20.
//  Copyright © 2020 Ankit Chaudhary. All rights reserved.
//

import Foundation
import UIKit

class MGSwipeExpansionSettings: NSObject {
    /// index of the expandable button (in the left or right buttons arrays)
    var buttonIndex : Int!
    /// if true the button fills the cell on trigger, else it bounces back to its initial position
    var fillOnTrigger = false
    /// Size proportional threshold to trigger the expansion button. Default value 1.5
    var threshold: CGFloat!
    /// Optional expansion color. Expanded button's background color is used by default *
    var expansionColor: UIColor?
    /// Defines the layout of the expanded button *
    var expansionLayout: MGSwipeExpansionLayout?
    /// Animation settings when the expansion is triggered *
    var triggerAnimation: MGSwipeAnimation!
    /// Property to read or change expansion animation durations. Default value 0.2
    /// The target animation is the change of a button from normal state to expanded state
    var animationDuration: CGFloat!
    
    override init() {
        super.init()
        buttonIndex = -1
        threshold = 1.3
        animationDuration = 0.2
        triggerAnimation = MGSwipeAnimation()
    }
}
