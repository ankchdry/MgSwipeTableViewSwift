//
//  MGSwipeSettings.swift
//  MgSwipeTableViewSwift
//
//  Created by Ankit Chaudhary on 31/07/20.
//  Copyright © 2020 Ankit Chaudhary. All rights reserved.
//

import Foundation
import UIKit
class MGSwipeSettings: NSObject {
    var transition: MGSwipeTransition?
    var threshold: CGFloat?
    var offset: CGFloat?
    var expandLastButtonBySafeAreaInsets: Bool!
    var keepButtonsSwiped: Bool!
    var enableSwipeBounces: Bool!
    var swipeBounceRate: CGFloat!
    var showAnimation: MgSwipeAnimation!
    var hideAnimation: MgSwipeAnimation!
    var stretchAnimation: MgSwipeAnimation!
    
    override init() {
        super.init()
        transition = .border
        threshold = 0.5
        offset = 0
        expandLastButtonBySafeAreaInsets = true
        keepButtonsSwiped = true
        enableSwipeBounces = true
        swipeBounceRate = 1.0
        showAnimation = MgSwipeAnimation()
        hideAnimation = MgSwipeAnimation()
        stretchAnimation = MgSwipeAnimation()
    }
    
    func setAnimationDuration(_ duration: CGFloat) {
        showAnimation.duration = duration
        hideAnimation.duration = duration
        stretchAnimation.duration = duration
    }
    
    var animationDuration: TimeInterval {
        return TimeInterval.init(showAnimation?.duration ?? 0)
    }
}
